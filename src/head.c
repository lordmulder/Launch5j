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
#ifndef JAR_FILE_WRAPPED
#define JAR_FILE_WRAPPED 0
#endif
#ifndef DETECT_REGISTRY
#define DETECT_REGISTRY 0
#endif
#ifndef REQUIRE_JAVA
#define REQUIRE_JAVA 8
#endif
#ifndef REQUIRE_BITNESS
#define REQUIRE_BITNESS 0
#endif
#ifndef ENABLE_SPLASH
#define ENABLE_SPLASH 1
#endif
#ifndef STAY_ALIVE
#define STAY_ALIVE 1
#endif
#ifndef WAIT_FOR_WINDOW
#define WAIT_FOR_WINDOW 1
#endif

// Sanity check
#if (REQUIRE_JAVA < 5) || (REQUIRE_JAVA > 255)
#error Invalid REQUIRE_JAVA value!
#endif
#if (REQUIRE_BITNESS != 0) && (REQUIRE_BITNESS != 32) && (REQUIRE_BITNESS != 64)
#error Invalid REQUIRE_BITNESS value!
#endif

// Dependant
#if (REQUIRE_BITNESS == 64)
#define REQUIRE_BITNESS_CPUARCH "x64"
#else
#define REQUIRE_BITNESS_CPUARCH "x86"
#endif

// Const
static const wchar_t *const JRE_RELATIVE_PATH = L"runtime\\bin\\javaw.exe";
static const wchar_t *const JRE_DOWNLOAD_LINK = L"https://adoptopenjdk.net/";
static const DWORD SPLASH_SCREEN_TIMEOUT = 30000U;
static const ULONGLONG JAVA_MINIMUM_VERSION = ((ULONGLONG)(REQUIRE_JAVA)) << 48;

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
    if(NOT_EMPTY(path))
    {
        size_t len = wcslen(path);
        while ((len > 0U) && ((path[len-1U] == L'\\') || (path[len-1U] == L'/')))
        {
            path[--len] = L'\0';
        }
    }
    return path;
}

static BOOL file_exists(const wchar_t *const filename) {
    struct _stat buffer;
    if (_wstat(filename, &buffer) == 0)
    {
        return S_ISDIR(buffer.st_mode) ? FALSE : TRUE;
    }
    return FALSE;
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
            if(LoadStringW(hinstance, id, buffer, str_len) > 0)
            {
                return wcstrim(buffer);
            }
            free(buffer);
        }
    }
    return NULL;
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
#if JAR_FILE_WRAPPED
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
    const HKEY root_key;
    const wchar_t *const base_reg_path;
    ULONGLONG version;
    const wchar_t *runtime_path;
}
java_home_t;

static ULONGLONG parse_java_version(const wchar_t *const version_str)
{
    ULONGLONG version = 0ULL;
    UINT level = 0U;

    if (NOT_EMPTY(version_str))
    {
        wchar_t *const temp = wcsdup(version_str);
        if (temp)
        {
            static const wchar_t *const delimiters = L".,_+";
            BOOL first_token = TRUE;
            const wchar_t *token = wcstok(temp, delimiters);
            while (token)
            {
                const DWORD component = wcstoul(token, NULL, 10);
                if (!(first_token && (component == 1U)))
                {
                    version = (version << 16) | (component & 0xFFFF);
                    ++level;
                }
                token = wcstok(NULL, delimiters);
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

    BOOL is_valid = FALSE;
    wchar_t *const java_home_path = reg_read_string(root_key, full_reg_path, L"JavaHome", flag_x64);
    trim_trailing_separator(wcstrim(java_home_path));
    if (NOT_EMPTY(java_home_path))
    {
        for (size_t i = 0U; REL_PATHS[i]; ++i)
        {
            wchar_t *const java_executable_path = awprintf(REL_PATHS[i], java_home_path);
            if (java_executable_path)
            {
                if (file_exists(java_executable_path))
                {
                    free(java_home_path);
                    return java_executable_path;
                }
                free(java_executable_path);
            }
        }
    }

    free(java_home_path);
    return NULL;
}

static BOOL detect_java_runtime_callback(const wchar_t *const key_name, const ULONG_PTR user_data)
{
    const ULONGLONG version = parse_java_version(key_name);
    if(version > JAVA_MINIMUM_VERSION)
    {
        java_home_t *const ptr = (java_home_t*) user_data;
        if(version > ptr->version)
        {
            wchar_t *const full_reg_path = awprintf(L"%ls\\%ls", ptr->base_reg_path, key_name);
            if (full_reg_path)
            {
                const wchar_t *const java_runtime_path = detect_java_runtime_verify(ptr->flag_x64, ptr->root_key, full_reg_path);
                if(java_runtime_path)
                {
                    SET_STRING(ptr->runtime_path, java_runtime_path);
                    ptr->version = version;
                }
                free(full_reg_path);
            }
        }
    }
    return TRUE;
}

static const wchar_t *detect_java_runtime_loop(const BOOL flag_x64)
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
            java_home_t state = { flag_x64, HKEY_LOCAL_MACHINE, REG_KEY_PATHS[i][j], version, runtime_path };
            reg_enum_subkeys(HKEY_LOCAL_MACHINE, REG_KEY_PATHS[i][j], flag_x64, detect_java_runtime_callback, (ULONG_PTR)&state);
            version = state.version;
            runtime_path = state.runtime_path;
        }
        if ((version > JAVA_MINIMUM_VERSION) && runtime_path)
        {
            return runtime_path;
        }
    }

    return NULL;
}

static const wchar_t *detect_java_runtime(void)
{
    const wchar_t *java_runtime;
#if (REQUIRE_BITNESS != 32)
    if(java_runtime = running_on_64bit() ? detect_java_runtime_loop(TRUE) : NULL)
    {
        return java_runtime;
    }
#endif
#if (REQUIRE_BITNESS != 64)
    if(java_runtime = detect_java_runtime_loop(FALSE))
    {
        return java_runtime;
    }
#endif
    return NULL;
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
    DWORD process_id = MAXDWORD;
    find_window_t *const ptr = (find_window_t*) lparam;
    if(IsWindowVisible(hwnd))
    {
        GetWindowThreadProcessId(hwnd, &process_id);
        if(process_id == ptr->process_id)
        {
            ptr->hwnd = hwnd;
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
        if (input_idle || signaled_or_failed(WaitForInputIdle(process_handle, 125U)))
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

static void show_jre_download_notice(const HWND hwnd)
{
    const DWORD REQUIRED_VERSION[] =
    {
        (JAVA_MINIMUM_VERSION >> 48) & 0xFFFF, (JAVA_MINIMUM_VERSION >> 32) & 0xFFFF,
        (JAVA_MINIMUM_VERSION >> 16) & 0xFFFF, JAVA_MINIMUM_VERSION & 0xFFFF
    };
    wchar_t *const version_str = (REQUIRED_VERSION[3U] != 0U)
        ? awprintf(L"%u.%u.%u_%u", REQUIRED_VERSION[0U], REQUIRED_VERSION[1U], REQUIRED_VERSION[2U], REQUIRED_VERSION[3U])
        : ((REQUIRED_VERSION[2U] != 0U) 
            ? awprintf(L"%u.%u.%u", REQUIRED_VERSION[0U], REQUIRED_VERSION[1U], REQUIRED_VERSION[2U])
            : awprintf(L"%u.%u", REQUIRED_VERSION[0U], REQUIRED_VERSION[1U]));
    if(version_str)
    {
        if (show_message_format(hwnd, MB_ICONWARNING | MB_OKCANCEL | MB_TOPMOST, L"JRE not found",
            L"This application requires the Java Runtime Environment, version %ls, or a compatible newer version.\n\n"
#if (REQUIRE_BITNESS != 0)
            L"Only the " XSTR(REQUIRE_BITNESS) "-Bit (" REQUIRE_BITNESS_CPUARCH ") version of the JRE is supported!\n\n"
#endif
            L"We recommend downloading the OpenJDK runtime here:\n%ls", version_str, JRE_DOWNLOAD_LINK) == IDOK)
        {
            ShellExecuteW(hwnd, NULL, JRE_DOWNLOAD_LINK, NULL, NULL, SW_SHOW);
        }
        free(version_str);
    }
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

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    int result = -1;
    const wchar_t *executable_path = NULL, *executable_directory = NULL, *jarfile_path = NULL, *java_runtime_path = NULL, *jvm_extra_args = NULL, *cmd_extra_args = NULL, *command_line = NULL;
    HGDIOBJ splash_image = NULL;
    PROCESS_INFORMATION process_info;
    STARTUPINFOW startup_info;

    // Initialize
    SecureZeroMemory(&startup_info, sizeof(STARTUPINFOW));
    SecureZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

    // Create the window
    HWND hwnd = CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_TOPMOST, L"STATIC", L"", WS_POPUP | SS_BITMAP, 0, 0, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInstance, NULL);

    // Show the splash screen
#if ENABLE_SPLASH
    if (splash_image = LoadImage(hInstance, MAKEINTRESOURCE(ID_BITMAP_SPLASH), IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE))
    {
        if (create_splash_screen(hwnd, splash_image))
        {
            process_window_messages(hwnd);
        }
    }
#endif

    // Find executable path
    if (!(executable_path = get_executable_path()))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"The path of the executable could not be determined!");
        goto cleanup;
    }

    // Find executable directory
    if (!(executable_directory = get_executable_directory(executable_path)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"The executable directory could not be determined!");
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
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"The path of the JAR file could not be determined!");
        goto cleanup;
    }

    // Does the JAR file exist?
#if !JAR_FILE_WRAPPED
    if (!file_exists(jarfile_path))
    {
        show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, L"JAR not found", L"The required JAR file could not be found:\n\n%ls\n\n\nRe-installing the application may fix the problem!", jarfile_path);
        goto cleanup;
    }
#endif

    // Find the Java runtime executable path (possibly from the registry)
#if DETECT_REGISTRY
    if (!(java_runtime_path = detect_java_runtime()))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"JRE not found", L"Java Runtime Environment (JRE) could not be found!");
        show_jre_download_notice(hwnd);
        goto cleanup;
    }
#else
    if (!(java_runtime_path = awprintf(L"%ls\\%ls", executable_directory, JRE_RELATIVE_PATH)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"The path of the Java runtime could not be determined!");
        goto cleanup;
    }
    if (!file_exists(java_runtime_path))
    {
        show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, L"JRE not found", L"The required Java runtime could not be found:\n\n%ls\n\n\nRe-installing the application may fix the problem!", java_runtime_path);
        goto cleanup;
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
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"The Java command-line could not be generated!");
        goto cleanup;
    }

    // Process pending window messages
#if ENABLE_SPLASH
    process_window_messages(hwnd);
#endif

    // Now actually start the process!
    if (!CreateProcessW(NULL, (LPWSTR)command_line, NULL, NULL, FALSE, 0U, NULL, executable_directory, &startup_info, &process_info))
    {
        const wchar_t *const error_text = describe_system_error(GetLastError());
        if (error_text)
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"Failed to create the Java process:\n\n%ls\n\n\n%ls", command_line, error_text);
            free((void*)error_text);
        }
        else
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, L"System Error", L"Failed to create the Java process:\n\n%ls", command_line);
        }
        goto cleanup;
    }

    // Process pending window messages
#if ENABLE_SPLASH
    process_window_messages(hwnd);
#if WAIT_FOR_WINDOW
    wait_for_process_ready(hwnd, process_info.hProcess, process_info.dwProcessId);
#endif
    destroy_window(&hwnd);
#endif

    // Wait for process to exit, then get the exit code
#if STAY_ALIVE
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

    destroy_window(&hwnd);
    delete_object(&splash_image);

    free((void*)jvm_extra_args);
    free((void*)cmd_extra_args);
    free((void*)command_line);
    free((void*)java_runtime_path);
    free((void*)jarfile_path);
    free((void*)executable_directory);
    free((void*)executable_path);

    return result;
}
