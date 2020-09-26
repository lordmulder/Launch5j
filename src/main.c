#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <direct.h>

#define WIN32_LEAN_AND_MEAN 1
#include <Windows.h>

static const wchar_t *const JRE_RELATIVE_PATH = L"runtime\\bin\\javaw.exe";

/* ======================================================================== */
/* String routines                                                          */
/* ======================================================================== */

#define NOT_EMPTY(STR) ((STR) && ((STR)[0U]))

static wchar_t *awprintf(const wchar_t *const fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    
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

static wchar_t *remove_file_extension(const wchar_t *const path)
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

static BOOL file_exists(const wchar_t *const filename) {
    struct _stat buffer;
    if (_wstat(filename, &buffer) == 0)
    {
        return S_ISDIR(buffer.st_mode) ? FALSE : TRUE;
    }
    return FALSE;
}

/* ======================================================================== */
/* Path detection                                                           */
/* ======================================================================== */

static const wchar_t *const DEFAULT_JARFILE_NAME = L"application.jar";

static const wchar_t *get_executable_path(void)
{
    if (_wpgmptr && _wpgmptr[0U])
    {
        return wcsdup(_wpgmptr);
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
    const wchar_t *jarfile_path = NULL;

    const wchar_t *const path_prefix = remove_file_extension(executable_path);
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

#define show_message(HWND, FLAGS, TITLE, TEXT) \
{ \
    MessageBoxW((HWND), (TEXT), (TITLE), (FLAGS)); \
} \
while(0)

#define show_message_format(HWND, FLAGS, TITLE, FORMAT, ...) do \
{ \
    const wchar_t *const _text = awprintf((FORMAT), __VA_ARGS__); \
    if(_text) \
    { \
        MessageBoxW((HWND), _text, (TITLE), (FLAGS)); \
    } \
    free((void*)_text); \
} \
while(0)

/* ======================================================================== */
/* MAIN                                                                     */
/* ======================================================================== */

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    int exit_code = -1;
    const wchar_t *executable_path = NULL, *executable_directory = NULL, *jarfile_path = NULL, *java_runtime_path = NULL, *command_line = NULL;
    STARTUPINFOW startup_info;
    PROCESS_INFORMATION process_info;

    // Initialize
    SecureZeroMemory(&startup_info, sizeof(STARTUPINFOW));
    SecureZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

    // Find executable path
    if(!(executable_path = get_executable_path()))
    {
        show_message(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"The path of the executable could not be determined!");
        goto cleanup;
    }

    // Find executable directory
    if(!(executable_directory = get_executable_directory(executable_path)))
    {
        show_message(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"The executable directory could not be determined!");
        goto cleanup;
    }

    // Set the current directory
    if(_wcsicmp(executable_directory, L".") != 0)
    {
        set_current_directory(executable_directory);
    }

    // Find the JAR file path
    if(!(jarfile_path = get_jarfile_path(executable_path, executable_directory)))
    {
        show_message(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"The path of the JAR file could not be determined!");
        goto cleanup;
    }

    // Find the Java runtime path
    if(!(java_runtime_path = awprintf(L"%ls\\%ls", executable_directory, JRE_RELATIVE_PATH)))
    {
        show_message(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"The path of the Java runtime could not be determined!");
        goto cleanup;
    }

    // Does JAR file exist?
    if(!file_exists(jarfile_path))
    {
        show_message_format(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"JAR not found", L"The required JAR file could not be found:\n\n%ls\n\n\nRe-installing the application may fix the problem!", jarfile_path);
        goto cleanup;
    }

    // Does the Java runtime exist?
    if(!file_exists(java_runtime_path))
    {
        show_message_format(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"Java not found", L"The required Java runtime could not be found:\n\n%ls\n\n\nRe-installing the application may fix the problem!", java_runtime_path);
        goto cleanup;
    }

    // Build the command-line
    command_line = NOT_EMPTY(pCmdLine) ? awprintf(L"\"%ls\" -jar \"%ls\" %ls", java_runtime_path, jarfile_path, pCmdLine) : awprintf(L"\"%ls\" -jar \"%ls\"", java_runtime_path, jarfile_path);
    if(!command_line)
    {
        show_message(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"The Java command-line could not be generated!");
        goto cleanup;
    }

    // Now actually start the process!
    if(!CreateProcessW(NULL, (LPWSTR)command_line, NULL, NULL, FALSE, 0U, NULL, executable_directory, &startup_info, &process_info))
    {
        const wchar_t *const error_text = describe_system_error(GetLastError());
        if(error_text)
        {
            show_message_format(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"Failed to create the Java process:\n\n%ls\n\n\n%ls", command_line, error_text);
            free((void*)error_text);
        }
        else
        {
            show_message_format(NULL, MB_ICONERROR | MB_SYSTEMMODAL, L"System Error", L"Failed to create the Java process:\n\n%ls", command_line);
        }
        goto cleanup;
    }

cleanup:

    if(process_info.hThread)
    {
        CloseHandle(process_info.hThread);
    }

    if(process_info.hProcess)
    {
        CloseHandle(process_info.hProcess);
    }

    free((void*)command_line);
    free((void*)java_runtime_path);
    free((void*)jarfile_path);
    free((void*)executable_directory);
    free((void*)executable_path);

    return exit_code;
}
