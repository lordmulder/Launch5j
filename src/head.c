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

#define UNICODE 1
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
#include <commctrl.h>

// Resources
#include "resource.h"

// Options
#ifndef L5J_ENABLE_GUI
#error  L5J_ENABLE_GUI flag is *not* defined!
#endif
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
#ifndef L5J_ENCODE_ARGS
#error  L5J_ENCODE_ARGS flag is *not* defined!
#endif
#ifndef L5J_WAIT_FOR_WINDOW
#define L5J_WAIT_FOR_WINDOW 1
#endif

// Const
static const wchar_t *const JRE_DOWNLOAD_LINK_DEFAULT = L"https://adoptopenjdk.net/";
static const wchar_t *const JRE_RELATIVE_PATH_DEFAULT = L"runtime\\bin";
static const wchar_t *const JRE_EXECUTABLE_NAME = L5J_ENABLE_GUI ? L"javaw.exe" : L"java.exe";
static const size_t MIN_MUTEXID_LENGTH = 5U;
static const DWORD SPLASH_SCREEN_TIMEOUT = 30000U;

// Check platform
#if !defined(_M_X64) && !defined(_M_IX86)
#error Unknown target platform!
#endif

// Boolean value
#define BOOLIFY(X) ((X) ? TRUE : FALSE)

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

static wchar_t *vaswprintf(const wchar_t *const fmt, va_list ap)
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

    const int result = _vsnwprintf(buffer, ((size_t)str_len) + 1U, fmt, ap);
    if (result < 1)
    {
        free(buffer);
        buffer = NULL;
    }

    return buffer;
}

static wchar_t *aswprintf(const wchar_t *const fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    wchar_t *const buffer = vaswprintf(fmt, ap);

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

static const wchar_t *skip_leading_spaces(const wchar_t *const str)
{
    if (NOT_EMPTY(str))
    {
        const wchar_t *result;
        for (result = str; (*result) && iswspace(*result); ++result);
        return result;
    }
    return str;
}

static BOOL starts_with(const wchar_t *const str, const wchar_t *const prefix)
{
    const size_t prefix_len = wcslen(prefix);
    if (wcsnicmp(skip_leading_spaces(str), prefix, prefix_len) == 0)
    {
        if ((!str[prefix_len]) || iswspace(str[prefix_len]))
        {
            return TRUE;
        }
    }
    return FALSE;
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
/* Character encoding                                                       */
/* ======================================================================== */

static const char *const HEX_CHARS = "0123456789ABCDEF";

static CHAR *utf16_to_bytes(const wchar_t *const input, const UINT code_page)
{
    CHAR *buffer;
    DWORD buffer_size = 0U, result = 0U;

    buffer_size = WideCharToMultiByte(code_page, 0, input, -1, NULL, 0, NULL, NULL);
    if(buffer_size < 1U)
    {
        return NULL;
    }

    buffer = (CHAR*) malloc(sizeof(CHAR) * buffer_size);
    if(!buffer)
    {
        return NULL;
    }

    result = WideCharToMultiByte(code_page, 0, input, -1, (LPSTR)buffer, buffer_size, NULL, NULL);
    if((result > 0U) && (result <= buffer_size))
    {
        return buffer;
    }

    free(buffer);
    return NULL;
}

static BOOL char_needs_encoding(const CHAR c)
{
    if (((c >= '0') && (c <= '9')) || ((c >= 'A') && (c <= 'Z')) || ((c >= 'a') && (c <= 'z')))
    {
        return FALSE;
    }
    if ((c == '-') || (c == '_') || (c == '.') || (c == '*') || (c == ' '))
    {
        return FALSE;
    }
    return TRUE;
}

static size_t url_encoded_length(const CHAR *const input)
{
    if ((input) && input[0U])
    {
        size_t length = strlen(input);
        for (size_t i = 0U; input[i]; ++i)
        {
            if (char_needs_encoding(input[i]))
            {
                length += 2U;
            }
        }
        return length + 1U;
    }
    return 0U;
}

static const wchar_t *url_encode_str(const CHAR *const input)
{
    const size_t buffer_size = url_encoded_length(input);
    if(buffer_size < 1U)
    {
        return NULL;
    }

    wchar_t *buffer = (wchar_t*) malloc(sizeof(wchar_t) * buffer_size);
    if (!buffer)
    {
        return NULL;
    }

    size_t j = 0U;
    for (size_t i = 0U; input[i]; ++i)
    {
        if (char_needs_encoding(input[i]))
        {
            buffer[j++] = L'%';
            buffer[j++] = (wchar_t) HEX_CHARS[(((BYTE)input[i]) >> 4) & 0xF];
            buffer[j++] = (wchar_t) HEX_CHARS[ ((BYTE)input[i])       & 0xF];
        }
        else
        {
            buffer[j++] = (wchar_t) ((input[i] != ' ') ? input[i] : '+');
        }
    }

    buffer[j] = '\0';
    return buffer;
}

/* ======================================================================== */
/* System information                                                       */
/* ======================================================================== */

typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE hProcess, PBOOL wow64Process);

static BOOL running_on_64bit(void)
{
#ifndef _M_X64
    const HMODULE kernel32 = GetModuleHandleW(L"kernel32");
    if (kernel32)
    {
        const LPFN_ISWOW64PROCESS ptr_is_wow64_process = (LPFN_ISWOW64PROCESS) GetProcAddress(kernel32,"IsWow64Process");
        if (ptr_is_wow64_process)
        {
            BOOL is_wow64_flag = FALSE;
            if (ptr_is_wow64_process(GetCurrentProcess(), &is_wow64_flag))
            {
                return is_wow64_flag;
            }
        }
    }
    return FALSE;
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

static const wchar_t *get_short_path(const wchar_t *const path)
{
    DWORD buff_len = 0U;
    wchar_t *buffer = NULL;

    if (NOT_EMPTY(path))
    {
        for (;;)
        {
            const DWORD result = GetShortPathNameW(path, buffer, buff_len);
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

static DWORD file_is_executable(const wchar_t *const file_path)
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
        if ((buffer = (wchar_t*) malloc(sizeof(wchar_t) * (str_len + 1U))))
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

static BOOL reg_key_exists(const HKEY root_key, const wchar_t *const path, const BOOL view_64bit)
{
    HKEY key = NULL;
    if (RegOpenKeyEx(root_key, path, 0U, KEY_QUERY_VALUE | get_registry_view(view_64bit), &key) == ERROR_SUCCESS)
    {
        RegCloseKey(key);
        return TRUE;
    }
    
    return FALSE;
}

static DWORD reg_read_dword(const HKEY root_key, const wchar_t *const path, const wchar_t *const name, const BOOL view_64bit, const DWORD error_value)
{
    HKEY key = NULL;
    if (RegOpenKeyEx(root_key, path, 0U, KEY_QUERY_VALUE | get_registry_view(view_64bit), &key) != ERROR_SUCCESS)
    {
        return FALSE;
    }
    
    DWORD value = 0U, type = 0U, size = sizeof(DWORD);
    LSTATUS status = RegQueryValueExW(key, name, NULL, &type, (LPBYTE)&value, &size);
    if ((status != ERROR_SUCCESS) || (size != sizeof(DWORD)) || ((type != REG_DWORD) && (type != REG_DWORD_BIG_ENDIAN)))
    {
        RegCloseKey(key);
        return error_value;
    }

    RegCloseKey(key);
    return value;
}


static wchar_t *reg_read_string(const HKEY root_key, const wchar_t *const path, const wchar_t *const name, const BOOL view_64bit)
{
    HKEY key = NULL;
    if (RegOpenKeyEx(root_key, path, 0U, KEY_QUERY_VALUE | get_registry_view(view_64bit), &key) != ERROR_SUCCESS)
    {
        return FALSE;
    }
    
    DWORD buffer_len = MAX_PATH;
    BYTE *buffer = (BYTE*) malloc(sizeof(wchar_t) * buffer_len);
    if (!buffer)
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
            jarfile_path = aswprintf(L"%s.jar", path_prefix);
        }
    }

    if (!jarfile_path)
    {
        jarfile_path = NOT_EMPTY(executable_directory) ? aswprintf(L"%s\\%s", executable_directory, DEFAULT_JARFILE_NAME) : wcsdup(DEFAULT_JARFILE_NAME);
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
    const struct
    {
        DWORD bitness;
        ULONGLONG ver_min;
        ULONGLONG ver_max;
    }
    required;
    const struct
    {
        HKEY root_key;
        const wchar_t *base_path;
        BOOL view_64bit;
    }
    registry;
    struct
    {
        DWORD bitness;
        ULONGLONG version;
        const wchar_t *runtime_path;
    }
    result;
}
java_home_t;

static BOOL detect_update_format(const wchar_t *const version_str)
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
    if (digit_flag && version_str[pos])
    {
        return (version_str[pos] == L'u') || (version_str[pos] == L'U');
    }
    return FALSE;
}

static ULONGLONG parse_java_version(const wchar_t *const version_str)
{
    ULONGLONG version = 0ULL;
    UINT level = 0U;
    static const wchar_t *const delimiters = L".,_+-uUbB";

    if (NOT_EMPTY(version_str))
    {
        wchar_t *const temp = wcsdup(version_str);
        if (temp)
        {
            const BOOL is_update_forma = detect_update_format(temp);
            BOOL first_token = TRUE;
            const wchar_t *token = wcstok(temp, delimiters);
            while (token)
            {
                const DWORD component = wcstoul(token, NULL, 10);
                if (!(first_token && (component == 1U)))
                {
                    version = (version << 16) | (component & 0xFFFF);
                    ++level;
                    if(is_update_forma && (level == 1U))
                    {
                        version <<= 16;
                        ++level;
                    }
                }
                if (level > 3U)
                {
                    break;
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

static DWORD detect_java_runtime_verify(const wchar_t **const executable_path_out, const HKEY root_key, const wchar_t *const full_reg_path, const BOOL reg_view_64bit)
{
    static const wchar_t *const JAVA_REG_NAMES[] = { L"JavaHome", L"Path", L"InstallationPath", NULL };
    static const wchar_t *const JAVA_EXE_PATHS[] = { L"%s\\jre\\bin\\%s", L"%s\\bin\\%s", NULL };

    *executable_path_out = NULL;
    DWORD result = 0U;

    for (size_t i = 0U; JAVA_REG_NAMES[i] && (!result); ++i)
    {
        wchar_t *const java_home_path = reg_read_string(root_key, full_reg_path, JAVA_REG_NAMES[i], reg_view_64bit);
        if(java_home_path)
        {
            trim_trailing_separator(wcstrim(java_home_path));
            if (NOT_EMPTY(java_home_path))
            {
                for (size_t j = 0U; JAVA_EXE_PATHS[j] && (!result); ++j)
                {
                    const wchar_t *const java_executable_path = aswprintf(JAVA_EXE_PATHS[j], java_home_path, JRE_EXECUTABLE_NAME);
                    if (java_executable_path)
                    {
                        const wchar_t *const absolute_executable_path = get_absolute_path(java_executable_path);
                        if (absolute_executable_path)
                        {
                            const DWORD bitness = file_is_executable(absolute_executable_path);
                            if (bitness > 0U)
                            {
                                *executable_path_out = absolute_executable_path;
                                result = bitness;
                            }
                            else
                            {
                                free((void*)absolute_executable_path);
                            }
                        }
                        free((void*)java_executable_path);
                    }
                }
            }
            free(java_home_path);
        }
    }

    return result;
}

static BOOL detect_java_runtime_scan_javasoft(const wchar_t *const key_name, const ULONG_PTR user_data)
{
    java_home_t *const context_ptr = (java_home_t*) user_data;
    ULONGLONG version = parse_java_version(key_name);

    if ((version >= context_ptr->required.ver_min) && (version < context_ptr->required.ver_max) && (version > context_ptr->result.version))
    {
        const wchar_t *const full_reg_path = aswprintf(L"%s\\%s", context_ptr->registry.base_path, key_name);
        if (full_reg_path)
        {
            const wchar_t *java_runtime_path;
            const DWORD bitness = detect_java_runtime_verify(&java_runtime_path, context_ptr->registry.root_key, full_reg_path, context_ptr->registry.view_64bit);
            if (bitness > 0U)
            {
                if (((context_ptr->required.bitness == 0U) || (bitness == context_ptr->required.bitness)) && (bitness >= context_ptr->result.bitness))
                {
                    context_ptr->result.bitness = bitness;
                    context_ptr->result.version = version;
                    SET_STRING(context_ptr->result.runtime_path, java_runtime_path);
                }
                else
                {
                    free((void*)java_runtime_path);
                }
            }
            free((void*)full_reg_path);
        }
    }

    return TRUE;
}

static BOOL detect_java_runtime_scan_adoptjdk(const wchar_t *const key_name, const ULONG_PTR user_data)
{
    static const wchar_t *const JVM_NATURE[] = { L"hotspot", L"openj9", NULL };

    java_home_t *const context_ptr = (java_home_t*) user_data;
    ULONGLONG version = parse_java_version(key_name);

    if ((version >= context_ptr->required.ver_min) && (version < context_ptr->required.ver_max) && (version > context_ptr->result.version))
    {
        for (size_t i = 0; JVM_NATURE[i]; ++i)
        {
            const wchar_t *const full_reg_path = aswprintf(L"%s\\%s\\%s\\MSI", context_ptr->registry.base_path, key_name, JVM_NATURE[i]);
            if (full_reg_path)
            {
                if (reg_key_exists(context_ptr->registry.root_key, full_reg_path, context_ptr->registry.view_64bit))
                {
                    const wchar_t *java_runtime_path;
                    const DWORD bitness = detect_java_runtime_verify(&java_runtime_path, context_ptr->registry.root_key, full_reg_path, context_ptr->registry.view_64bit);
                    if (bitness > 0U)
                    {
                        if (((context_ptr->required.bitness == 0U) || (bitness == context_ptr->required.bitness)) && (bitness >= context_ptr->result.bitness))
                        {
                            context_ptr->result.bitness = bitness;
                            context_ptr->result.version = version;
                            SET_STRING(context_ptr->result.runtime_path, java_runtime_path);
                        }
                        else
                        {
                            free((void*)java_runtime_path);
                        }
                    }
                }
                free((void*)full_reg_path);
            }
        }
    }

    return TRUE;
}

static BOOL detect_java_runtime_scan_liberica(const wchar_t *const key_name, const ULONG_PTR user_data)
{
    java_home_t *const context_ptr = (java_home_t*) user_data;

    const wchar_t *const full_reg_path = aswprintf(L"%s\\%s", context_ptr->registry.base_path, key_name);
    if (full_reg_path)
    {
        const DWORD value_major = reg_read_dword(context_ptr->registry.root_key, full_reg_path, L"MajorVersion", context_ptr->registry.view_64bit, 0U);
        const DWORD value_minor = reg_read_dword(context_ptr->registry.root_key, full_reg_path, L"MinorVersion", context_ptr->registry.view_64bit, 0U);
        const DWORD value_build = reg_read_dword(context_ptr->registry.root_key, full_reg_path, L"BuildNumber",  context_ptr->registry.view_64bit, 0U);
        const ULONGLONG version = (((ULONGLONG)(value_major & 0xFFFF)) << 48) | (((ULONGLONG)(value_minor & 0xFFFF)) << 16) | ((ULONGLONG)(value_build  & 0xFFFF));
        if ((version >= context_ptr->required.ver_min) && (version < context_ptr->required.ver_max) && (version > context_ptr->result.version))
        {
            const wchar_t *java_runtime_path;
            const DWORD bitness = detect_java_runtime_verify(&java_runtime_path, context_ptr->registry.root_key, full_reg_path, context_ptr->registry.view_64bit);
            if (bitness > 0U)
            {
                if (((context_ptr->required.bitness == 0U) || (bitness == context_ptr->required.bitness)) && (bitness >= context_ptr->result.bitness))
                {
                    context_ptr->result.bitness = bitness;
                    context_ptr->result.version = version;
                    SET_STRING(context_ptr->result.runtime_path, java_runtime_path);
                }
                else
                {
                    free((void*)java_runtime_path);
                }
            }
        }
        free((void*)full_reg_path);
    }

    return TRUE;
}

static const wchar_t *detect_java_runtime(const DWORD required_bitness, const ULONGLONG required_ver_min, const ULONGLONG required_ver_max)
{
    typedef struct { UINT mode; const wchar_t *path; } reg_key_t;
    static const reg_key_t REG_KEYS[] =
    {
        { 1U, L"SOFTWARE\\JavaSoft\\Java Runtime Environment" }, { 1U, L"SOFTWARE\\JavaSoft\\JRE" }, { 2U, L"SOFTWARE\\AdoptOpenJDK\\JRE" },
        { 1U, L"SOFTWARE\\JavaSoft\\Java Development Kit"     }, { 1U, L"SOFTWARE\\JavaSoft\\JDK" }, { 2U, L"SOFTWARE\\AdoptOpenJDK\\JDK" },
        { 3U, L"SOFTWARE\\BellSoft\\Liberica" },
        { 3U, L"SOFTWARE\\Azul Systems\\Zulu" }, { 0U, NULL }
    };

    const wchar_t *runtime_path = NULL;
    DWORD bitness = 0U;
    ULONGLONG version = 0U;

    for (UINT i = running_on_64bit() ? 0U : 1U; i < 2U; ++i)
    {
        const BOOL reg_view_64bit = (i < 1U);
        for (size_t j = 0U; REG_KEYS[j].mode && REG_KEYS[j].path; ++j)
        {
            java_home_t search_state =
            {
                { required_bitness, required_ver_min, required_ver_max },
                { HKEY_LOCAL_MACHINE, REG_KEYS[j].path, reg_view_64bit },
                { bitness, version, NULL }
            };
            switch(REG_KEYS[j].mode)
            {
            case 1U:
                reg_enum_subkeys(HKEY_LOCAL_MACHINE, REG_KEYS[j].path, reg_view_64bit, detect_java_runtime_scan_javasoft, (ULONG_PTR)&search_state);
                break;
            case 2U:
                reg_enum_subkeys(HKEY_LOCAL_MACHINE, REG_KEYS[j].path, reg_view_64bit, detect_java_runtime_scan_adoptjdk, (ULONG_PTR)&search_state);
                break;
            case 3U:
                reg_enum_subkeys(HKEY_LOCAL_MACHINE, REG_KEYS[j].path, reg_view_64bit, detect_java_runtime_scan_liberica, (ULONG_PTR)&search_state);
                break;
            }
            if(search_state.result.runtime_path)
            {
                bitness = search_state.result.bitness;
                version = search_state.result.version;
                SET_STRING(runtime_path, search_state.result.runtime_path);
            }
        }
    }

    if (((required_bitness == 0U) || (bitness == required_bitness)) && (version >= required_ver_min) && (version < required_ver_max) && runtime_path)
    {
        return runtime_path;
    }

    free((void*)runtime_path);
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

static const wchar_t *get_java_full_path(const wchar_t *const jre_base_path, const wchar_t *const jre_relative_path)
{
    const wchar_t *const relative_path_ptr = AVAILABLE(jre_relative_path) ? skip_leading_separator(jre_relative_path) : NULL;
    return aswprintf(L"%s\\%s\\%s", jre_base_path, NOT_EMPTY(relative_path_ptr) ? relative_path_ptr: JRE_RELATIVE_PATH_DEFAULT, JRE_EXECUTABLE_NAME);
}

/* ======================================================================== */
/* Command-line                                                             */
/* ======================================================================== */

static wchar_t *encode_commandline_args(const int argc, const LPWSTR *const argv)
{
    if (!(argv && (argc > 0)))
    {
        return NULL;
    }

    const CHAR **argv_utf8 = (const CHAR**) malloc(sizeof(CHAR*) * argc);
    if(!argv_utf8)
    {
        return NULL;
    }

    size_t total_len = 0U;
    for (int i = 0; i < argc; ++i)
    {
        argv_utf8[i] = utf16_to_bytes(argv[i], CP_UTF8);
        if (argv_utf8[i])
        {
            total_len += argv_utf8[i][0U] ? url_encoded_length(argv_utf8[i]) : 3U;
        }
    }

    wchar_t *result_buffer = NULL;
    if (total_len > 0U)
    {
        if ((result_buffer = (wchar_t*) calloc(total_len, sizeof(wchar_t))))
        {
            for (int i = 0; i < argc; ++i)
            {
                if (argv_utf8[i])
                {
                    if (result_buffer[0U])
                    {
                        wcscat(result_buffer, L" ");
                    }
                    if (argv_utf8[i][0U])
                    {
                        const wchar_t *const arg_encoded = url_encode_str(argv_utf8[i]);
                        if (arg_encoded)
                        {
                            wcscat(result_buffer, arg_encoded);
                            free((void*)arg_encoded);
                        }
                    }
                    else
                    {
                        wcscat(result_buffer, L"\"\"");
                    }
                    free((void*)argv_utf8[i]);
                }
            }
        }
    }

    free(argv_utf8);
    return result_buffer;
}

static const wchar_t *encode_commandline_str(const wchar_t *const command_line)
{
    const wchar_t * encoded = NULL;
    if (NOT_EMPTY(command_line))
    {
        int argc = 0;
        const LPWSTR *const argv = CommandLineToArgvW(command_line, &argc);
        if (argv)
        {
             encoded = encode_commandline_args(argc, argv);
             LocalFree((HLOCAL)argv);
        }
    }
    return encoded;
}

static const wchar_t *build_commandline(const DWORD pid, const wchar_t *const java_runtime_path, const wchar_t *const jar_file_path, const wchar_t *const jvm_extra_args, const wchar_t *const cmd_extra_args, const wchar_t *const cmd_input_args)
{
    const wchar_t *command_line;

    const wchar_t *const jarfile_short_path = get_short_path(jar_file_path);
    const wchar_t *const jarfile_ptr = NOT_EMPTY(jarfile_short_path) ? jarfile_short_path : jar_file_path;

#if L5J_ENCODE_ARGS
    const wchar_t *const ext_args_encoded = AVAILABLE(cmd_extra_args) ? encode_commandline_str(cmd_extra_args) : NULL;
    const wchar_t *const cmd_args_encoded = NOT_EMPTY(cmd_input_args) ? encode_commandline_str(cmd_input_args) : NULL;
#else
    const wchar_t *const ext_args_encoded = AVAILABLE(cmd_extra_args) ? skip_leading_spaces(cmd_extra_args) : NULL;
    const wchar_t *const cmd_args_encoded = NOT_EMPTY(cmd_input_args) ? skip_leading_spaces(cmd_input_args) : NULL;
#endif

    if (NOT_EMPTY(ext_args_encoded))
    {
        command_line = AVAILABLE(jvm_extra_args)
            ? aswprintf(NOT_EMPTY(cmd_args_encoded) ? L"\"%s\" %s -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s %s" : L"\"%s\" %s -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s", java_runtime_path, jvm_extra_args, pid, BOOLIFY(L5J_ENCODE_ARGS), jarfile_ptr, ext_args_encoded, cmd_args_encoded)
            : aswprintf(NOT_EMPTY(cmd_args_encoded) ? L"\"%s\" -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s %s"    : L"\"%s\" -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s",    java_runtime_path,                 pid, BOOLIFY(L5J_ENCODE_ARGS), jarfile_ptr, ext_args_encoded, cmd_args_encoded);
    }
    else
    {
        command_line = AVAILABLE(jvm_extra_args)
            ? aswprintf(NOT_EMPTY(cmd_args_encoded) ? L"\"%s\" %s -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s" : L"\"%s\" %s -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\"", java_runtime_path, jvm_extra_args, pid, BOOLIFY(L5J_ENCODE_ARGS), jarfile_ptr, cmd_args_encoded)
            : aswprintf(NOT_EMPTY(cmd_args_encoded) ? L"\"%s\" -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\" %s"    : L"\"%s\" -Dl5j.pid=%u -Dl5j.encargs=%u -jar \"%s\"",    java_runtime_path,                 pid, BOOLIFY(L5J_ENCODE_ARGS), jarfile_ptr, cmd_args_encoded);
    }

#if L5J_ENCODE_ARGS
    free((void*)ext_args_encoded);
    free((void*)cmd_args_encoded);
#endif

    free((void*)jarfile_short_path);
    return command_line;
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

#if L5J_ENABLE_GUI
#define show_message(HWND, FLAGS, TITLE, TEXT) MessageBoxW((HWND), (TEXT), (TITLE), (FLAGS))
#else
#define show_message(HWND, FLAGS, TITLE, TEXT) ({ const int _retval = __ms_fwprintf(stderr, L"%s\n", (TEXT)); fflush(stderr); _retval; })
#endif

static int show_message_format(HWND hwnd, const DWORD flags, const wchar_t *const title, const wchar_t *const format, ...)
{
    int result = -1;
    va_list ap;
    va_start(ap, format);

    const wchar_t *const text = vaswprintf(format, ap );
    if(NOT_EMPTY(text))
    {
        result = show_message(hwnd, flags, title, text);
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
        ? aswprintf(L"%u.%u.%u_%u", req_version_comp[0U], req_version_comp[1U], req_version_comp[2U], req_version_comp[3U])
        : ((req_version_comp[2U] != 0U) 
            ? aswprintf(L"%u.%u.%u", req_version_comp[0U], req_version_comp[1U], req_version_comp[2U])
            : aswprintf(L"%u.%u", req_version_comp[0U], req_version_comp[1U]));
    if(version_str)
    {
        const wchar_t *const jre_download_ptr = IS_HTTP_URL(jre_download_link) ? jre_download_link : JRE_DOWNLOAD_LINK_DEFAULT;
        const int result = (required_bitness == 0U)
            ? show_message_format(hwnd, MB_ICONINFORMATION | MB_OKCANCEL | MB_TOPMOST, title,
                L"This application requires the Java Runtime Environment, version %s, or a compatible newer version.\n\n"
                L"We recommend downloading the OpenJDK runtime here:\n%s",
                version_str, jre_download_ptr)
            : show_message_format(hwnd, MB_ICONINFORMATION | MB_OKCANCEL | MB_TOPMOST, title,
                L"This application requires the Java Runtime Environment, version %s, or a compatible newer version.\n\n"
                L"Only the %u-Bit (%s) version of the JRE is supported!\n\n"
                L"We recommend downloading the OpenJDK runtime here:\n%s",
                version_str, required_bitness, (required_bitness == 64) ? L"x64" : L"x86", jre_download_ptr);
        if (result == IDOK)
        {
            ShellExecuteW(hwnd, NULL, jre_download_ptr, NULL, NULL, SW_SHOW);
        }
    }
    free(version_str);
    free(jre_download_link);
}

static void show_about_dialogue(const HWND hwnd)
{
#ifdef _M_X64
    const wchar_t *const CPU_ARCH = L"x64";
#else
    const wchar_t *const CPU_ARCH = L"x86";
#endif
    show_message_format(hwnd, MB_ICONINFORMATION, L"About Launch5j",
        L"Launch5j (%s), by LoRd_MuldeR <MuldeR2@GMX.de>\n"
            L"v%u.%u.%u, build %u, created %s %s\n\n"
            L"This work has been released under the MIT license.\n"
            L"For details, please see:\n"
            L"https://opensource.org/licenses/MIT\n\n"
            L"Check the project website for news and updates:\n"
            L"https://github.com/lordmulder/\n\n"
            L"Build options:\n"
            L"JAR_FILE_WRAPPED=%d, DETECT_REGISTRY=%d, ENABLE_SPLASH=%d, STAY_ALIVE=%d, ENCODE_ARGS=%d, WAIT_FOR_WINDOW=%d",
        CPU_ARCH, L5J_VERSION_MAJOR, L5J_VERSION_MINOR, L5J_VERSION_PATCH, L5J_BUILDNO, TEXT(__DATE__), TEXT(__TIME__),
        L5J_JAR_FILE_WRAPPED, L5J_DETECT_REGISTRY, L5J_ENABLE_SPLASH, L5J_STAY_ALIVE, L5J_ENCODE_ARGS, L5J_WAIT_FOR_WINDOW);
}

static void enable_slunk_mode(const HWND hwnd)
{
    const WORD DATA[45U] =
    {
        0x1924, 0x82AB, 0x5252, 0xC021, 0xE1A3, 0x3969, 0xFEE5, 0x4A4A, 0x93E3, 0x3470, 0xDED9, 0x3A97, 0x12E1, 0xC694, 0xF5A7,
        0x8539, 0x82A9, 0x864D, 0x8853, 0x5E0F, 0x4803, 0x45CC, 0x19B7, 0x391A, 0x0753, 0x1936, 0x6ECA, 0xCAEA, 0xA340, 0x5574,
        0x8A94, 0x0620, 0x405A, 0x8D0B, 0xB221, 0x1FC5, 0x42A4, 0x95BB, 0x689A, 0x8C61, 0x4EEC, 0x82CA, 0x728B, 0xFE59, 0x47B8
    };
    UINT32 mask = 0xB499E87D;
    wchar_t slunk[45U];
    for(size_t i = 0; i < 45U; ++i)
    {
        mask = mask * 214013U + 2531011U;
        slunk[i] = (wchar_t) ((DATA[i] ^ mask) & 0xFFFF);
    }
    ShellExecute(hwnd, NULL, slunk, NULL, NULL, SW_SHOW);
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

    const wchar_t *const mutex_uuid = aswprintf(L"l5j.%016llX%016llX", hashcode_0, hashcode_1);
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

static int launch5j_main(const HINSTANCE hinstance, const wchar_t *const cmd_line_args)
{
    int result = -1;
    const wchar_t *app_heading = NULL, *mutex_name = NULL, *executable_path = NULL, *executable_directory = NULL, *jarfile_path = NULL,
        *java_runtime_path = NULL, *jre_relative_path = NULL, *jvm_extra_args = NULL, *cmd_extra_args = NULL, *command_line = NULL;
    HANDLE mutex_handle = NULL;
    DWORD java_required_bitness = 0U;
    ULONGLONG java_required_ver_min = 0ULL, java_required_ver_max = 0ULL;
    HWND hwnd = NULL;
    HGDIOBJ splash_image = NULL;
    BOOL have_screen_created = FALSE;
    PROCESS_INFORMATION process_info;
    STARTUPINFOW startup_info;

    // Ensure that the ComCtl32 DLL is loaded
#if L5J_ENABLE_GUI
    InitCommonControls(); 
#endif

    // Initialize
    SecureZeroMemory(&startup_info, sizeof(STARTUPINFOW));
    SecureZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

    // Get current process ID
    const DWORD pid = GetCurrentProcessId();

    // Load title
    app_heading = load_string(hinstance, ID_STR_HEADING);

    // Create the window
#if L5J_ENABLE_GUI
    hwnd = CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_TOPMOST, L"STATIC", APP_HEADING, WS_POPUP | SS_BITMAP, 0, 0, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hinstance, NULL);
#endif

    // Show about screen?
    if (starts_with(cmd_line_args, L"--l5j-about"))
    {
        show_about_dialogue(hwnd);
        return 0;
    }
    if (starts_with(cmd_line_args, L"--l5j-slunk"))
    {
        enable_slunk_mode(hwnd);
        return 0;
    }

    // Single instance
#if L5J_STAY_ALIVE
    mutex_name = load_string(hinstance, ID_STR_MUTEXID);
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
    if ((splash_image = LoadImage(hinstance, MAKEINTRESOURCE(ID_BITMAP_SPLASH), IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE)))
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
        show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The required JAR file could not be found:\n\n%s\n\n\nRe-installing the application may fix the problem!", jarfile_path);
        goto cleanup;
    }
#endif

    // Find the Java runtime executable path (possibly from the registry)
#if L5J_DETECT_REGISTRY
    java_required_ver_min = load_java_version(hinstance, ID_STR_JAVAMIN, (8ull << 48));
    java_required_ver_max = load_java_version(hinstance, ID_STR_JAVAMAX, MAXULONGLONG);
    java_required_bitness = load_java_bitness(hinstance, ID_STR_BITNESS);
    if (!(java_runtime_path = detect_java_runtime(java_required_bitness, java_required_ver_min, java_required_ver_max)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Java Runtime Environment (JRE) could not be found!");
        show_jre_download_notice(hinstance, hwnd, APP_HEADING, java_required_bitness, java_required_ver_min);
        goto cleanup;
    }
#else
    jre_relative_path = load_string(hinstance, ID_STR_JREPATH);
    if (!(java_runtime_path = get_java_full_path(executable_path, jre_relative_path)))
    {
        show_message(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The path of the Java runtime could not be determined!");
        goto cleanup;
    }
    if (!BOOLIFY(file_is_executable(java_runtime_path)))
    {
        show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"The Java runtime could not be found or is invalid:\n\n%s\n\n\nRe-installing the application may fix the problem!", java_runtime_path);
        goto cleanup;
    }
#endif

    // Load additional options
    jvm_extra_args = load_string(hinstance, ID_STR_JVMARGS);
    cmd_extra_args = load_string(hinstance, ID_STR_CMDARGS);

    // Make sure command-line was created
    command_line = build_commandline(pid, java_runtime_path, jarfile_path, jvm_extra_args, cmd_extra_args, cmd_line_args);
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
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Failed to create the Java process:\n\n%s\n\n\n%s", command_line, error_text);
            free((void*)error_text);
        }
        else
        {
            show_message_format(hwnd, MB_ICONERROR | MB_TOPMOST, APP_HEADING, L"Failed to create the Java process:\n\n%s", command_line);
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

#if L5J_ENABLE_GUI
    destroy_window(&hwnd);
    delete_object(&splash_image);
#endif

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

/* ======================================================================== */
/* Entry points                                                             */
/* ======================================================================== */

#if L5J_ENABLE_GUI
int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    return launch5j_main(hInstance, pCmdLine);
}
#else
extern HINSTANCE __mingw_winmain_hInstance;
extern LPWSTR __mingw_winmain_lpCmdLine;
int wmain(int argc, wchar_t **argv, wchar_t **envp)
{
    return launch5j_main(__mingw_winmain_hInstance, __mingw_winmain_lpCmdLine);
}
#endif
