/************************************************************/
/* Launch5j, by LoRd_MuldeR <MuldeR2@GMX.de>                */
/* Java JAR wrapper for creating Windows native executables */
/* https://github.com/lordmulder/                           */
/*                                                          */
/* This work has been released under the MIT license.       */
/* Please see LICENSE.TXT for details!                      */
/*                                                          */
/* ACKNOWLEDGEMENT                                          */
/* This project is partly inspired by the Launch4j project: */
/* https://sourceforge.net/p/launch4j/                      */
/************************************************************/

#define WIN32_LEAN_AND_MEAN 1

// CRT
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <direct.h>

// Win32 API
#include <Windows.h>
#include <shellapi.h>

// Resources
#include "resource.h"

// Options
#ifndef L5J_JAR_FILE_WRAPPED
#error  L5J_JAR_FILE_WRAPPED flag is *not* defined!
#endif
#ifndef L5J_DETECT_REGISTRY
#error  L5J_DETECT_REGISTRY flag is *not* defined!
#endif
#ifndef L5J_ENABLE_SPLASH
#error  L5J_ENABLE_SPLASH flag is *not* defined!
#endif
#ifndef L5J_STAY_ALIVE
#error  L5J_STAY_ALIVE flag is *not* defined!
#endif
#ifndef L5J_WAIT_FOR_WINDOW
#define L5J_WAIT_FOR_WINDOW 1
#endif

// Const
static const wchar_t *const JRE_DOWNLOAD_LINK_DEFAULT = L"https://adoptopenjdk.net/";
static const wchar_t *const JRE_RELATIVE_PATH_DEFAULT = L"runtime\\bin\\javaw.exe";
static const size_t MIN_MUTEXID_LENGTH = 5U;
static const DWORD SPLASH_SCREEN_TIMEOUT = 30000U;

/* ======================================================================== */
/* String routines                                                          */
/* ======================================================================== */

#define XSTR(S) STR(S)
#define STR(S) #S

#define NOT_EMPTY(STR) ((STR) && ((STR)[0U]))
#define AVAILABLE(OPT) (NOT_EMPTY(OPT) && (wcscmp((OPT), L"?") != 0))

#define SET_STRING(DST,SRC) do \
{ \
    if((DST)) { free((void*)(DST)); } \
    (DST) = (SRC); \
} \
while(0)


static wchar_t *vawprintf(const wchar_t *const fmt, va_list ap)
{
    const int str_len = _vscwprintf(fmt, ap);
    if (str_len < 1)
    {
        return NULL;
    }

    wchar_t *buffer = (wchar_t*) malloc(sizeof(wchar_t) * (((size_t)str_len) + 1U));
    if (!buffer)
    {
        return NULL;
    }

    const int result = vswprintf(buffer, ((size_t)str_len) + 1U, fmt, ap);
    if (result < 1)
    {
        free(buffer);
        buffer = NULL;
    }

    return buffer;
}

static wchar_t *awprintf(const wchar_t *const fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    wchar_t *const buffer = vawprintf(fmt, ap);

    va_end(ap);
    return buffer;
}

static wchar_t *wcsndup (const wchar_t *const str, const size_t n)
{
    size_t str_len = wcslen(str);
    if (n < str_len)
    {
        str_len = n;
    }

    wchar_t *const result = (wchar_t*) malloc(sizeof(wchar_t) * (str_len + 1U));
    if (!result)
    {
        return NULL;
    }

    wcsncpy(result, str, str_len);
    result[str_len] = '\0';
    return result;
}

static wchar_t *wcstrim(wchar_t *const str)
{
    if (NOT_EMPTY(str))
    {
        size_t pos = 0U, out = 0U;
        while (str[pos] && iswspace(str[pos]))
        {
            ++pos;
        }
        if (pos > 0U)
        {
            while(str[pos])
            {
                str[out++] = str[pos++];
            }
            str[out] = L'\0';
        }
        else
        {
            for (; str[out]; ++out);
        }
        while ((out > 0U) && (iswspace(str[out-1U])))
        {
            str[--out] = L'\0';
        }
    }
    return str;
}

/* ======================================================================== */
/* System information                                                       */
/* ======================================================================== */

typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);

static BOOL running_on_64bit(void)
{
#ifndef _M_X64
    BOOL is_wow64_flag = FALSE;
    const LPFN_ISWOW64PROCESS is_wow64_process = (LPFN_ISWOW64PROCESS) GetProcAddress(GetModuleHandleW(L"kernel32"),"IsWow64Process");
    if (is_wow64_process)
    {
        if (!is_wow64_process(GetCurrentProcess(), &is_wow64_flag))
        {
            is_wow64_flag = FALSE;
        }
    }
    return is_wow64_flag;
#else
    return TRUE;
#endif
}

/* ======================================================================== */
/* File name routines                                                       */
/* ======================================================================== */

static wchar_t *get_directory_part(const wchar_t *const path)
{
    size_t lastsep = SIZE_MAX;

    if(NOT_EMPTY(path))
    {
        for (size_t i = 0; path[i]; ++i)
        {
            if ((path[i] == L'\\') || (path[i] == L'/'))
            {
                lastsep = i;
            }
        }
    }

    if (lastsep != SIZE_MAX)
    {
        return wcsndup(path, lastsep);
    }

    return wcsdup(L".");
}

static wchar_t *get_path_without_suffix(const wchar_t *const path)
{
    size_t lastsep = SIZE_MAX;
    size_t lastdot = SIZE_MAX;

    for (size_t i = 0; path[i]; ++i)
    {
        if ((path[i] == L'\\') || (path[i] == L'/'))
        {
            lastsep = i;
        }
        else if (path[i] == L'.')
        {
            lastdot = i;
        }
    }

    if (lastdot != SIZE_MAX)
    {
        if((lastsep == SIZE_MAX) || (lastdot > lastsep))
        {
            return wcsndup(path, lastdot);
        }
    }

    return wcsdup(path);
}

static wchar_t * trim_trailing_separator(wchar_t *const path)
{
    if (NOT_EMPTY(path))
    {
        size_t len = wcslen(path);
        while ((len > 0U) && ((path[len-1U] == L'\\') || (path[len-1U] == L'/')))
        {
            path[--len] = L'\0';
        }
    }
    return path;
}

static const wchar_t *skip_leading_separator(const wchar_t *path)
{
    if (NOT_EMPTY(path))
    {
        for (; (*path) && ((*path == L'\\') || (*path == L'/')); ++path);
    }
    return path;
}

static const wchar_t *get_absolute_path(const wchar_t *const path)
{
    DWORD buff_len = 0U;
    wchar_t *buffer = NULL;

    if (NOT_EMPTY(path))
    {
        for (;;)
        {
            const DWORD result = GetFullPathNameW(path, buff_len, buffer, NULL);
            if (result > 0U)
            {
                if (result < buff_len)
                {
                    return buffer;
                }
                else
                {
                    if (!(buffer = (wchar_t*) realloc(buffer, sizeof(wchar_t) * (buff_len = result))))
                    {
                        break;
                    }
                }
            }
            else
            {
                break; /*error*/
            }
        }
    }

    free(buffer);
    return NULL;
}

static BOOL file_exists(const wchar_t *const filename) {
    struct _stat buffer;
    if (_wstat(filename, &buffer) == 0)
    {
        return S_ISDIR(buffer.st_mode) ? FALSE : TRUE;
    }
    return FALSE;
}

static UINT file_is_executable(const wchar_t *const file_path)
{
    DWORD binary_type = 0U;
    if(GetBinaryTypeW(file_path, &binary_type))
    {
        switch(binary_type)
        {
        case SCS_32BIT_BINARY:
            return 32U;
        case SCS_64BIT_BINARY:
            return 64U;
        }
    }
    return 0U;
}

/* ======================================================================== */
/* Resource routines                                                        */
/* ======================================================================== */

static wchar_t *load_string(const HINSTANCE hinstance, const UINT id)
{
    wchar_t *buffer;
    const int str_len = LoadStringW(hinstance, id, (PWCHAR)&buffer, 0);
    if(str_len > 0)
    {
        if (buffer = (wchar_t*) malloc(sizeof(wchar_t) * (str_len + 1U)))
        {
            if(LoadStringW(hinstance, id, buffer, str_len + 1U) > 0)
            {
                return wcstrim(buffer);
            }
            free(buffer);
        }
    }
    return NULL;
}

static DWORD load_uint32(const HINSTANCE hinstance, const UINT id, const DWORD fallback)
{
    DWORD value = fallback;
    const wchar_t *const str = load_string(hinstance, id);
    if(NOT_EMPTY(str))
    {
        value = wcstoul(str, NULL, 10);
    }
    free((void*)str);
    return value;
}

/* ======================================================================== */
/* Registry routines                                                        */
/* ======================================================================== */

typedef BOOL (*reg_enum_callback_t)(const wchar_t *const key_name, const ULONG_PTR user_data);

static DWORD get_registry_view(const BOOL view_64bit)
{
#ifndef _M_X64
    return view_64bit ? KEY_WOW64_64KEY : 0U;
#else
    return view_64bit ? 0U : KEY_WOW64_32KEY;
#endif
}

static wchar_t *reg_read_string(const HKEY root_key, const wchar_t *const path, const wchar_t *const name, const BOOL view_64bit)
{
    HKEY key = NULL;
    if(RegOpenKeyEx(root_key, path, 0U, KEY_QUERY_VALUE | get_registry_view(view_64bit), &key) != ERROR_SUCCESS)
    {
        return FALSE;
    }
    
    DWORD buffer_len = MAX_PATH;
    BYTE *buffer = (BYTE*) malloc(sizeof(wchar_t) * buffer_len);
    if(!buffer)
    {
        RegCloseKey(key);
        return NULL;
    }

    DWORD type = 0U, size = sizeof(wchar_t) * buffer_len;
    LSTATUS status = RegQueryValueExW(key, name, NULL, &type, buffer, &size);
    while (status == ERROR_MORE_DATA)
    {
        buffer_len = (buffer_len < 512U) ? 512U : (2U * buffer_len);
        BYTE *buffer = (BYTE*) realloc(buffer, size = (sizeof(wchar_t) * buffer_len));
        if(!buffer)
        {
            RegCloseKey(key);
            return NULL;
        }
        status = RegQueryValueExW(key, name, NULL, &type, buffer, &size);
    }
    if ((status != ERROR_SUCCESS) || (size < sizeof(wchar_t)) || ((type != REG_SZ) && (type != REG_EXPAND_SZ)))
    {
        free(buffer);
        RegCloseKey(key);
        return NULL;
    }

    const size_t char_count = size / sizeof(wchar_t);
    if (((wchar_t*)buffer)[char_count - 1U])
    {
        while (char_count >= buffer_len)
        {
            BYTE *buffer = (BYTE*) realloc(buffer, sizeof(wchar_t) * (buffer_len = char_count + 1U));
            if(!buffer)
            {
                RegCloseKey(key);
                return NULL;
            }
        }
        ((wchar_t*)buffer)[char_count] = L'\0';
    }

    RegCloseKey(key);
    return (wchar_t*) buffer;
}

static DWORD reg_read_string_uint32(const HKEY root_key, const wchar_t *const path, const wchar_t *const name, const BOOL view_64bit)
{
    DWORD value = 0;
    const wchar_t *const string = reg_read_string(root_key, path, name, view_64bit);
    if(NOT_EMPTY(string))
    {
        value = wcstoul(string, NULL, 10);
    }
    free((void*)string);
    return value;
}

static BOOL reg_enum_subkeys(const HKEY root_key, const wchar_t *const path, const BOOL view_64bit, const reg_enum_callback_t callback, const ULONG_PTR user_data)
{
    HKEY key = NULL;
    if(RegOpenKeyEx(root_key, path, 0U, KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | get_registry_view(view_64bit), &key) != ERROR_SUCCESS)
    {
        return FALSE;
    }

    DWORD max_len = 0U;
    if(RegQueryInfoKeyW(key, NULL, NULL, NULL, NULL, &max_len, NULL, NULL, NULL, NULL, NULL, NULL) != ERROR_SUCCESS)
    {
        RegCloseKey(key);
        return FALSE;
    }

    wchar_t *buffer = (wchar_t*) malloc(sizeof(wchar_t) * (max_len + 1U));
    if (!buffer)
    {
        RegCloseKey(key);
        return FALSE;
    }

    BOOL result = TRUE;
    for (DWORD index = 0U; index < MAXDWORD; ++index)
    {
        DWORD len = max_len + 1U;
        switch (RegEnumKeyExW(key, index, buffer, &len, NULL, NULL, NULL, NULL))
        {
        case ERROR_SUCCESS:
            if (!callback(buffer, user_data))
            {
                goto exit_loop;
            }
            break;
        case ERROR_MORE_DATA:
            result = FALSE;
            break;
        case ERROR_NO_MORE_ITEMS:
            goto exit_loop;
        default:
            result = FALSE;
            goto exit_loop;
        }
    }

exit_loop:

    RegCloseKey(key);
    free(buffer);
    return result;
}

/* ======================================================================== */
/* Path detection                                                           */
/* ======================================================================== */

static const wchar_t *const DEFAULT_JARFILE_NAME = L"application.jar";

static const wchar_t *get_executable_path(void)
{
    if (_wpgmptr && _wpgmptr[0U])
    {
        wchar_t *const executable_path = wcsdup(_wpgmptr);
        return wcstrim(executable_path);
    }
    return NULL;
}

static const wchar_t *get_executable_directory(const wchar_t *const executable_path)
{
    const wchar_t *const directory_part = get_directory_part(executable_path);
    if (directory_part)
    {
        return directory_part;
    }

    free((void*)directory_part);
    return wcsdup(L".");
}

static const wchar_t *get_jarfile_path(const wchar_t *const executable_path, const wchar_t *const executable_directory)
{
#if L5J_JAR_FILE_WRAPPED
    return wcsdup(executable_path); /*JAR file is wrapped*/
#else
    const wchar_t *jarfile_path = NULL;

    const wchar_t *const path_prefix = get_path_without_suffix(executable_path);
    if (NOT_EMPTY(path_prefix))
    {
        const size_t len = wcslen(path_prefix);
        if (!((len > 0U) && ((path_prefix[len-1U] == L'\\') || (path_prefix[len-1U] == L'/'))))
        {
            jarfile_path = awprintf(L"%ls.jar", path_prefix);
        }
    }

    if (!jarfile_path)
    {
        jarfile_path = NOT_EMPTY(executable_directory) ? awprintf(L"%ls\\%ls", executable_directory, DEFAULT_JARFILE_NAME) : wcsdup(DEFAULT_JARFILE_NAME);
    }

    free((void*)path_prefix);
    return jarfile_path;
#endif
}

/* ======================================================================== */
/* Path manipulation                                                        */
/* ======================================================================== */

static const BOOL set_current_directory(const wchar_t *const path)
{
    if(NOT_EMPTY(path))
    {
        if(iswalpha(path[0U]) && (path[1U] == L':') && (path[2U] == L'\0'))
        {
            const wchar_t root_path[4U] = { path[0U], L':', L'\\', L'\0' };
            return SetCurrentDirectoryW(root_path);
        }
        else
        {
            return SetCurrentDirectoryW(path);
        }
    }
    else
    {
        return SetCurrentDirectoryW(L"\\");
    }
}

/* ======================================================================== */
/* Java detection (from registry)                                           */
/* ======================================================================== */

typedef struct
{
    const BOOL flag_x64;
    const ULONGLONG required_ver_min;
    const ULONGLONG required_ver_max;
    const HKEY root_key;
    const wchar_t *const base_reg_path;
    ULONGLONG version;
    const wchar_t *runtime_path;
}
java_home_t;

static BOOL is_old_format(const wchar_t *const version_str)
{
    BOOL digit_flag = FALSE;
    size_t pos = 0U;
    while (version_str[pos] && iswspace(version_str[pos]))
    {
       ++pos;
    }
    while (version_str[pos] && iswdigit(version_str[pos]))
    {
       digit_flag = TRUE;
       ++pos;
    }
    while (version_str[pos] && iswspace(version_str[pos]))
    {
       ++pos;
    }
    if (digit_flag)
    {
        return (version_str[pos] == L'u') || (version_str[pos] == L'U');
    }
    return FALSE;
}

static ULONGLONG parse_java_version(const wchar_t *const version_str)
{
    ULONGLONG version = 0ULL;
    UINT level = 0U;

    if (NOT_EMPTY(version_str))
    {
        wchar_t *const temp = wcsdup(version_str);
        if (temp)
        {
            const BOOL old_format = is_old_format(temp);
            BOOL first_token = TRUE;
            const wchar_t *token = wcstok(temp, L".uU");
            while (token)
            {
                const DWORD component = wcstoul(token, NULL, 10);
                if (!(first_token && (component == 1U)))
                {
                    version = (version << 16) | (component & 0xFFFF);
                    ++level;
                    if(old_format && (level == 1U))
                    {
                        version <<= 16;
                        ++level;
                    }
                }
                if (level > 3U)
                {
                    break;
                }
                token = wcstok(NULL, L"._+-b");
                first_token = FALSE;
            }
        }
        free(temp);
    }

    while(level < 4U)
    {
        version <<= 16;
        ++level;
    }

    return version;
}

static const wchar_t *detect_java_runtime_verify(const BOOL flag_x64, const HKEY root_key, const wchar_t *const full_reg_path)
{
    static const wchar_t *const REL_PATHS[] =
    {
        L"%ls\\jre\\bin\\javaw.exe", L"%ls\\bin\\javaw.exe", NULL
    };

    const wchar_t *result = NULL;
    wchar_t *const java_home_path = reg_read_string(root_key, full_reg_path, L"JavaHome", flag_x64);
    trim_trailing_separator(wcstrim(java_home_path));

    if (NOT_EMPTY(java_home_path))
    {
        const UINT required_bitness = flag_x64 ? 64U : 32U;
        for (size_t i = 0U; REL_PATHS[i]; ++i)
        {
            const wchar_t *const java_executable_path = awprintf(REL_PATHS[i], java_home_path);
            if (java_executable_path)
            {
                const wchar_t *const full_executable_abspath = get_absolute_path(java_executable_path);
                if (full_executable_abspath)
                {
                    if (file_is_executable(full_executable_abspath) == required_bitness)
                    {
                        result = full_executable_abspath;
                        break;
                    }
                    free((void*)full_executable_abspath);
                }
                free((void*)java_executable_path);
            }
        }
    }

    free(java_home_path);
    return result;
}

static void patch_java_version(ULONGLONG *const version, const DWORD component_version, const UINT shift)
{
    if(component_version > 0U)
    {
        *version &= (~(((ULONGLONG)0xFFFF) << shift));
        *version |= (((ULONGLONG)(component_version & 0xFFFF)) << shift);
    }
}

static BOOL detect_java_runtime_callback(const wchar_t *const key_name, const ULONG_PTR user_data)
{
    java_home_t *const context_ptr = (java_home_t*) user_data;
    wchar_t *const full_reg_path = awprintf(L"%ls\\%ls", context_ptr->base_reg_path, key_name);
    if (full_reg_path)
    {
        ULONGLONG version = parse_java_version(key_name);
        patch_java_version(&version, reg_read_string_uint32(context_ptr->root_key, full_reg_path, L"MicroVersion",  context_ptr->flag_x64), 32U);
        patch_java_version(&version, reg_read_string_uint32(context_ptr->root_key, full_reg_path, L"UpdateVersion", context_ptr->flag_x64), 16U);
        patch_java_version(&version, reg_read_string_uint32(context_ptr->root_key, full_reg_path, L"BuildNumber",   context_ptr->flag_x64),  0U);
        if ((version >= context_ptr->required_ver_min) && (version < context_ptr->required_ver_max))
        {
            if (version > context_ptr->version)
            {
                const wchar_t *const java_executable_path = detect_java_runtime_verify(context_ptr->flag_x64, context_ptr->root_key, full_reg_path);
                if(java_executable_path)
                {
                    SET_STRING(context_ptr->runtime_path, java_executable_path);
                    context_ptr->version = version;
                }
            }
        }
        free(full_reg_path);
    }

    return TRUE;
}

static const wchar_t *detect_java_runtime_loop(const BOOL flag_x64, const ULONGLONG required_ver_min, const ULONGLONG required_ver_max)
{
    static const wchar_t *const REG_KEY_PATHS[2U][3U] =
    {
        { L"SOFTWARE\\JavaSoft\\Java Runtime Environment", L"SOFTWARE\\JavaSoft\\JRE", NULL },
        { L"SOFTWARE\\JavaSoft\\Java Development Kit",     L"SOFTWARE\\JavaSoft\\JDK", NULL }
    };

    ULONGLONG version = 0U;
    const wchar_t *runtime_path = NULL;

    for (size_t i = 0; i < 2U; ++i)
    {
        for (size_t j = 0; REG_KEY_PATHS[i][j]; ++j)
        {
            java_home_t state = { flag_x64, required_ver_min, required_ver_max, HKEY_LOCAL_MACHINE, REG_KEY_PATHS[i][j], version, NULL };
            reg_enum_subkeys(HKEY_LOCAL_MACHINE, REG_KEY_PATHS[i][j], flag_x64, detect_java_runtime_callback, (ULONG_PTR)&state);
            if((state.version > version) && state.runtime_path)
            {
                version = state.version;
                SET_STRING(runtime_path, state.runtime_path);
            }
            else
            {
                free((void*)state.runtime_path);
            }
        }
        if ((version >= required_ver_min) && (version < required_ver_max) && runtime_path)
        {
            return runtime_path;
        }
    }

    free((void*)runtime_path);
    return NULL;
}

static const wchar_t *detect_java_runtime(const DWORD required_bitness, const ULONGLONG required_ver_min, const ULONGLONG required_ver_max)
{
    const wchar_t *java_runtime_path;
    if (required_bitness != 32U)
    {
        if (java_runtime_path = running_on_64bit() ? detect_java_runtime_loop(TRUE, required_ver_min, required_ver_max) : NULL)
        {
            return java_runtime_path;
        }
    }
    if (required_bitness != 64U)
    {
        if(java_runtime_path = detect_java_runtime_loop(FALSE, required_ver_min, required_ver_max))
        {
            return java_runtime_path;
        }
    }
    return NULL;
}

static const ULONGLONG load_java_version(const HINSTANCE hinstance, const UINT id, const ULONGLONG fallback)
{
    ULONGLONG value = fallback;
    const wchar_t *const str = load_string(hinstance, id);
    if(NOT_EMPTY(str))
    {
        const ULONGLONG temp = parse_java_version(str);
        if(temp >= (5ull << 48))
        {
            value = temp;
        }
    }
    free((void*)str);
    return value;
}

static DWORD load_java_bitness(const HINSTANCE hinstance, const UINT id)
{
    const DWORD value = load_uint32(hinstance, id, 0U);
    return ((value == 32U) || (value == 64U)) ? value : 0U;
}

/* ======================================================================== */
/* Splash screen                                                            */
/* ======================================================================== */

static BOOL create_splash_screen(const HWND hwnd, const HANDLE splash_image)
{
    if (hwnd && splash_image)
    {
        RECT rect;
        SendMessageW(hwnd, STM_SETIMAGE, IMAGE_BITMAP, (LPARAM) splash_image);
        GetWindowRect(hwnd, &rect);
        const int x = (GetSystemMetrics(SM_CXSCREEN) - (rect.right - rect.left)) / 2;
        const int y = (GetSystemMetrics(SM_CYSCREEN) - (rect.bottom - rect.top)) / 2;
        SetWindowPos(hwnd, HWND_TOP, x, y, 0, 0, SWP_NOSIZE);
        ShowWindow(hwnd, SW_SHOW);
        return UpdateWindow(hwnd);
    }
    return FALSE;
}

static BOOL process_window_messages(const HWND hwnd)
{
    BOOL result = FALSE;
    if (hwnd != NULL)
    {
        MSG msg = {};
        for (DWORD k = 0U; k < MAXWORD; ++k)
        {
            if (PeekMessageW(&msg, hwnd, 0U, 0U, PM_REMOVE))
            {
                result = TRUE;
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
            else
            {
                break; /*no more messages!*/
            }
        }
    }
    return result;
}

/* ======================================================================== */
/* Find window functions                                                    */
/* ======================================================================== */

typedef struct
{
    const DWORD process_id;
    HWND hwnd;
}
find_window_t;

static BOOL CALLBACK enum_windows_callback(const HWND hwnd, const LPARAM lparam)
{
    find_window_t *const context_ptr = (find_window_t*)lparam;
    const DWORD required_process_id = context_ptr->process_id;
    if(IsWindowVisible(hwnd))
    {
        DWORD process_id = MAXDWORD;
        GetWindowThreadProcessId(hwnd, &process_id);
        if(process_id == required_process_id)
        {
            context_ptr->hwnd = hwnd;
            return FALSE;
        }
    }
    return TRUE;
}

static HWND find_window_by_process_id(const DWORD process_id)
{
    find_window_t find_window = { process_id, NULL };
    EnumWindows(enum_windows_callback, (LONG_PTR)&find_window);
    return find_window.hwnd;
}

/* ======================================================================== */
/* Wait for process                                                         */
/* ======================================================================== */

static BOOL signaled_or_failed(const DWORD wait_result)
{
    return (wait_result == WAIT_OBJECT_0) || (wait_result == WAIT_FAILED);
}

static BOOL wait_for_process_ready(const HWND hwnd, const HANDLE process_handle, const DWORD process_id)
{
    BOOL input_idle = FALSE;
    const DWORD ticks_start = GetTickCount();
    for (;;)
    {
        if (input_idle || signaled_or_failed(WaitForInputIdle(process_handle, 25U)))
        {
            const HWND child_hwnd = find_window_by_process_id(process_id);
            if (child_hwnd)
            {
                SwitchToThisWindow(child_hwnd, TRUE);
                return TRUE;
            }
            input_idle = TRUE;
        }
        if (signaled_or_failed(WaitForSingleObject(process_handle, 1U)))
        {
            break;
        }
        const DWORD ticks_delta = GetTickCount() - ticks_start;
        if(ticks_delta > SPLASH_SCREEN_TIMEOUT)
        {
            break;
        }
        process_window_messages(hwnd);
    }

    return FALSE;
}

/* ======================================================================== */
/* Message box                                                              */
/* ======================================================================== */

#define IS_HTTP_URL(STR) (NOT_EMPTY(STR) && ((wcsnicmp((STR), L"http://", 7U) == 0) || (wcsnicmp((STR), L"https://", 8U) == 0)))

static const wchar_t *describe_system_error(const DWORD error_code)
{
    const wchar_t *error_test = NULL, *buffer = NULL;

    const DWORD len = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER |FORMAT_MESSAGE_IGNORE_INSERTS, NULL, error_code, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR)&buffer, 0, NULL);
    if((len > 0U) && NOT_EMPTY(buffer))
    {
        error_test = wcsdup(buffer);
        LocalFree((HLOCAL)buffer);
    }

    return error_test;
}

#define show_message(HWND, FLAGS, TITLE, TEXT) MessageBoxW((HWND), (TEXT), (TITLE), (FLAGS))

static int show_message_format(HWND hwnd, const DWORD flags, const wchar_t *const title, const wchar_t *const format, ...)
{
    int result = -1;
    va_list ap;
    va_start(ap, format);

    const wchar_t *const text = vawprintf(format, ap );
    if(NOT_EMPTY(text))
    {
        result = MessageBoxW(hwnd, text, title, flags);
    }

    free((void*)text);
    return result;
}

static void show_jre_download_notice(const HINSTANCE hinstance, const HWND hwnd, const wchar_t *const title, const DWORD required_bitness, const ULONGLONG required_ver)
{
    const DWORD req_version_comp[] =
    {
        (required_ver >> 48) & 0xFFFF, (required_ver >> 32) & 0xFFFF, (required_ver >> 16) & 0xFFFF, required_ver & 0xFFFF
    };
    wchar_t *const jre_download_link = load_string(hinstance, ID_STR_JAVAURL);
    wchar_t *const version_str = (req_version_comp[3U] != 0U)
        ? awprintf(L"%u.%u.%u_%u", req_version_comp[0U], req_version_comp[1U], req_version_comp[2U], req_version_comp[3U])
        : ((req_version_comp[2U] != 0U) 
            ? awprintf(L"%u.%u.%u", req_version_comp[0U], req_version_comp[1U], req_version_comp[2U])
            : awprintf(L"%u.%u", req_version_comp[0U], req_version_comp[1U]));
    if(version_str)
    {
        const wchar_t *const jre_download_ptr = IS_HTTP_URL(jre_download_link) ? jre_download_link : JRE_DOWNLOAD_LINK_DEFAULT;
        const int result = (required_bitness == 0U)
            ? show_message_format(hwnd, MB_ICONWARNING | MB_OKCANCEL | MB_TOPMOST, title,
                L"This application requires the Java Runtime Environment, version %ls, or a compatible newer version.\n\n"
                L"We recommend downloading the OpenJDK runtime here:\n%ls",
                version_str, jre_download_ptr)
            : show_message_format(hwnd, MB_ICONWARNING | MB_OKCANCEL | MB_TOPMOST, title,
                L"This application requires the Java Runtime Environment, version %ls, or a compatible newer version.\n\n"
                L"Only the %u-Bit (%ls) version of the JRE is supported!\n\n"
                L"We recommend downloading the OpenJDK runtime here:\n%ls",
                version_str, required_bitness, (required_bitness == 64) ? L"x64" : L"x86", jre_download_ptr);
        if (result == IDOK)
        {
            ShellExecuteW(hwnd, NULL, jre_download_ptr, NULL, NULL, SW_SHOW);
        }
    }
    free(version_str);
    free(jre_download_link);
}

/* ======================================================================== */
/* Single instance                                                          */
/* ======================================================================== */

static ULONGLONG hash_code(const BYTE *const message, const size_t message_len)
{
    ULONGLONG hash = 0xCBF29CE484222325ull;
    for (size_t iter = 0U; iter < message_len; ++iter)
    {
        hash ^= message[iter];
        hash *= 0x00000100000001B3ull;
    }
    return hash;
}

static BOOL initialize_mutex(HANDLE *const handle, const wchar_t *const mutex_name)
{
    static const char *const BUILD_TIME = __DATE__ " " __TIME__;

    const ULONGLONG hashcode_0 = hash_code((const BYTE*)BUILD_TIME, sizeof(wchar_t) * strlen(BUILD_TIME));
    const ULONGLONG hashcode_1 = hash_code((const BYTE*)mutex_name, sizeof(wchar_t) * wcslen(mutex_name));

    const wchar_t *const mutex_uuid = awprintf(L"l5j.%016llX%016llX", hashcode_0, hashcode_1);
    if (!mutex_uuid)
    {
        return TRUE; /*better safe than sorry*/
    }

    BOOL result = TRUE;
    if ((*handle = CreateMutexW(NULL, TRUE, mutex_uuid)) != NULL)
    {
        if (GetLastError() == ERROR_ALREADY_EXISTS)
        {
            result = FALSE;
        }
    }

    free((void*)mutex_uuid);
    return result;
}

/* ======================================================================== */
/* Utilities                                                                */
/* ======================================================================== */

static void close_handle(HANDLE *const handle)
{
    if(*handle)
    {
        CloseHandle(*handle);
        *handle = NULL;
    }
}

static void delete_object(HGDIOBJ *const handle)
{
    if(*handle)
    {
        DeleteObject(*handle);
        *handle = NULL;
    }
}

static void destroy_window(HWND *const hwnd)
{
    if(*hwnd)
    {
        DestroyWindow(*hwnd);
        *hwnd = NULL;
    }
}

/* ======================================================================== */
/* MAIN                                                                     */
/* ======================================================================== */

static wchar_t *const DEFAULT_HEADING = L"Launch5j";
#define APP_HEADING (AVAILABLE(app_heading) ? app_heading : DEFAULT_HEADING)

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    int result = -1;
    const wchar_t *app_heading = NULL, *mutex_name = NULL, *executable_path = NULL, *executable_directory = NULL, *jarfile_path = NULL,
         *java_runtime_path = NULL, *jre_relative_path = NULL, *jvm_extra_args = NULL, *cmd_extra_args = NULL, *command_line = NULL;
    HANDLE mutex_handle = NULL;
    DWORD java_required_bitness = 0U;
    ULONGLONG java_required_ver_min = 0ULL, java_required_ver_max = 0ULL;
    HGDIOBJ splash_image = NULL;
    BOOL have_screen_created = FALSE;
    PROCESS_INFORMATION process_info;
    STARTUPINFOW startup_info;

    // Initialize
    SecureZeroMemory(&startup_info, sizeof(STARTUPINFOW));
    SecureZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

    // Load title
    app_heading = load_string(hInstance, ID_STR_HEADING);

    // Create the window
    HWND hwnd = CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_TOPMOST, L"STATIC", APP_HEADING, WS_POPUP | SS_BITMAP, 0, 0, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInstance, NULL);

    // Single instance
#if L5J_STAY_ALIVE
    mutex_name = load_string(hInstance, ID_STR_MUTEXID);
    if (AVAILABLE(mutex_name) && (wcslen(mutex_name) >= MIN_MUTEXID_LENGTH + ((mutex_name[0U] == L'@') ? 0U : 1U)))
    {
        if(!initialize_mutex(&mutex_handle, (mutex_name[0U] == L'@') ? mutex_name + 1U : mutex_name))
        {
            if(mutex_name[0U] != L'@')
            {
                show_message(hwnd, MB_ICONWARNING | MB_TOPMOST, APP_HEADING, L"The application is already running.\n\n"
                    L"If you see this message even though the application does not appear to be running, try restarting your computer!");
            }
            goto cleanup;
        }
    }
#endif

    // Show the splash screen
#if L5J_ENABLE_SPLASH
    if (splash_image = LoadImage(hInstance, MAKEINTRESOURCE(ID_BITMAP_SPLASH), IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE))
    {
        if (create_splash_screen(hwnd, splash_image))
        {
            have_screen_created = TRUE;
            process_window_messages(hwnd);
        }
    }
#endif

    // Find executable path
    if (!(executable_path = get_executable_path()))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The path of the executable could not be determined!");
        goto cleanup;
    }

    // Find executable directory
    if (!(executable_directory = get_executable_directory(executable_path)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The executable directory could not be determined!");
        goto cleanup;
    }

    // Set the current directory
    if (_wcsicmp(executable_directory, L".") != 0)
    {
        set_current_directory(executable_directory);
    }

    // Find the JAR file path
    if (!(jarfile_path = get_jarfile_path(executable_path, executable_directory)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The path of the JAR file could not be determined!");
        goto cleanup;
    }

    // Does the JAR file exist?
#if !L5J_JAR_FILE_WRAPPED
    if (!file_exists(jarfile_path))
    {
        show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The required JAR file could not be found:\n\n%ls\n\n\nRe-installing the application may fix the problem!", jarfile_path);
        goto cleanup;
    }
#endif

    // Find the Java runtime executable path (possibly from the registry)
#if L5J_DETECT_REGISTRY
    java_required_ver_min = load_java_version(hInstance, ID_STR_JAVAMIN, (8ull << 48));
    java_required_ver_max = load_java_version(hInstance, ID_STR_JAVAMAX, MAXULONGLONG);
    java_required_bitness = load_java_bitness(hInstance, ID_STR_BITNESS);
    if (!(java_runtime_path = detect_java_runtime(java_required_bitness, java_required_ver_min, java_required_ver_max)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Java Runtime Environment (JRE) could not be found!");
        show_jre_download_notice(hInstance, hwnd, APP_HEADING, java_required_bitness, java_required_ver_min);
        goto cleanup;
    }
#else
    jre_relative_path = load_string(hInstance, ID_STR_JREPATH);
    {
        const wchar_t *const relative_path_ptr = AVAILABLE(jre_relative_path) ? skip_leading_separator(jre_relative_path) : NULL;
        if (!(java_runtime_path = awprintf(L"%ls\\%ls", executable_directory, NOT_EMPTY(relative_path_ptr) ? relative_path_ptr: JRE_RELATIVE_PATH_DEFAULT)))
        {
            show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The path of the Java runtime could not be determined!");
            goto cleanup;
        }
        if (!file_is_executable(java_runtime_path))
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The Java runtime could not be found or is invalid:\n\n%ls\n\n\nRe-installing the application may fix the problem!", java_runtime_path);
            goto cleanup;
        }
    }
#endif

    // Load additional options
    jvm_extra_args = load_string(hInstance, ID_STR_JVMARGS);
    cmd_extra_args = load_string(hInstance, ID_STR_CMDARGS);

    // Build the command-line
    command_line = AVAILABLE(cmd_extra_args)
        ? (AVAILABLE(jvm_extra_args)
            ? awprintf(NOT_EMPTY(pCmdLine) ? L"\"%ls\" %ls -jar \"%ls\" %ls %ls" : L"\"%ls\" %ls -jar \"%ls\" %ls", java_runtime_path, jvm_extra_args, jarfile_path, cmd_extra_args, pCmdLine)
            : awprintf(NOT_EMPTY(pCmdLine) ? L"\"%ls\" -jar \"%ls\" %ls %ls"     : L"\"%ls\" -jar \"%ls\" %ls",     java_runtime_path,                 jarfile_path, cmd_extra_args, pCmdLine))
        : (AVAILABLE(jvm_extra_args)
            ? awprintf(NOT_EMPTY(pCmdLine) ? L"\"%ls\" %ls -jar \"%ls\" %ls" : L"\"%ls\" %ls -jar \"%ls\"", java_runtime_path, jvm_extra_args, jarfile_path, pCmdLine)
            : awprintf(NOT_EMPTY(pCmdLine) ? L"\"%ls\" -jar \"%ls\" %ls"     : L"\"%ls\" -jar \"%ls\"",     java_runtime_path,                 jarfile_path, pCmdLine));
    if (!command_line)
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The Java command-line could not be generated!");
        goto cleanup;
    }

    // Process pending window messages
#if L5J_ENABLE_SPLASH
    process_window_messages(hwnd);
#endif

    // Now actually start the process!
    if (!CreateProcessW(NULL, (LPWSTR)command_line, NULL, NULL, FALSE, 0U, NULL, executable_directory, &startup_info, &process_info))
    {
        const wchar_t *const error_text = describe_system_error(GetLastError());
        if (error_text)
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Failed to create the Java process:\n\n%ls\n\n\n%ls", command_line, error_text);
            free((void*)error_text);
        }
        else
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Failed to create the Java process:\n\n%ls", command_line);
        }
        goto cleanup;
    }

    // Process pending window messages
#if L5J_ENABLE_SPLASH
    process_window_messages(hwnd);

    // Wait until child-process window is showing
#if L5J_WAIT_FOR_WINDOW
    wait_for_process_ready(hwnd, process_info.hProcess, process_info.dwProcessId);
#endif
#endif

    // Hide the splash screen now
    if (have_screen_created)
    {
        ShowWindow(hwnd, SW_HIDE);
    }

    // Wait for process to exit, then get the exit code
#if L5J_STAY_ALIVE
    if (signaled_or_failed(WaitForSingleObject(process_info.hProcess, INFINITE)))
    {
        DWORD exit_code = 0U;
        if (GetExitCodeProcess(process_info.hProcess, &exit_code))
        {
            result = (int) exit_code;
        }
    }
#else
    result = 0;
#endif

cleanup:

    close_handle(&process_info.hThread);
    close_handle(&process_info.hProcess);
    close_handle(&mutex_handle);

    destroy_window(&hwnd);
    delete_object(&splash_image);

    free((void*)jvm_extra_args);
    free((void*)cmd_extra_args);
    free((void*)command_line);
    free((void*)java_runtime_path);
    free((void*)jarfile_path);
    free((void*)jre_relative_path);
    free((void*)executable_directory);
    free((void*)executable_path);
    free((void*)mutex_name);
    free((void*)app_heading);

    return result;
}
