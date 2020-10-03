@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Get current date
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set ISO_DATE=

for /F "usebackq tokens=1" %%a in (`start /WAIT /B "" "%~dp0.\etc\utils\core-utils\date.exe" +"%%Y-%%m-%%d"`) do (
	set "ISO_DATE=%%a"
)

if "%ISO_DATE%"=="" (
	echo Failed to determine the current date!
	pause
	goto:eof
)

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Build!
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set MAKE_NONINTERACTIVE=1

call ".\build.cmd"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Copy binaries
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set "PACK_PATH=%~dp0.\out\~pkg%RANDOM%"
rmdir /Q /S "%PACK_PATH%" 2> NUL

mkdir "%PACK_PATH%"
mkdir "%PACK_PATH%\x64"
mkdir "%PACK_PATH%\etc"
mkdir "%PACK_PATH%\etc\img"
mkdir "%PACK_PATH%\etc\css"
mkdir "%PACK_PATH%\example"

copy /Y "%~dp0.\*.txt"                   "%PACK_PATH%"
copy /Y "%~dp0.\*.html"                  "%PACK_PATH%"
copy /Y "%~dp0.\bin\launch5j_x86*.exe"   "%PACK_PATH%"
copy /Y "%~dp0.\bin\launch5j_amd64*.exe" "%PACK_PATH%\x64"
copy /Y "%~dp0.\etc\img\*.png"           "%PACK_PATH%\etc\img"
copy /Y "%~dp0.\etc\css\*.css"           "%PACK_PATH%\etc\css"

copy /Y /B "%~dp0.\bin\launch5j_x86_wrapped_registry.exe" + "%~dp0.\src\example\dist\example.jar" "%PACK_PATH%\example\example.exe"
copy /Y "%~dp0.\src\example\src\com\muldersoft\l5j\example\Main.java" "%PACK_PATH%\example\example.java"

attrib +R "%PACK_PATH%\*.*" /S

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Output file
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir "%~dp0.\out" 2> NUL

set /A COUNT=1
set "OUTFILE=%~dp0.\out\launch5j-bin.%ISO_DATE%"

:outfile_loop
if exist "%OUTFILE%.zip" goto:outfile_next
if exist "%OUTFILE%.7z"  goto:outfile_next
goto:outfile_done

:outfile_next
set /A COUNT=%COUNT%+1
set "OUTFILE=%~dp0.\out\launch5j-bin.%ISO_DATE%.r%COUNT%"
goto:outfile_loop

:outfile_done

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Create ZIP package
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pushd "%PACK_PATH%"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

echo.
echo ========================================================================
echo Creating ZIP
echo ========================================================================
echo.
"%~dp0.\etc\utils\info-zip\zip.exe" -r -9 "%OUTFILE%.zip" "*.*"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

attrib +R "%OUTFILE%.zip"

echo.
echo ========================================================================
echo Creating 7z
echo ========================================================================
echo.
"%~dp0.\etc\utils\7-zip\7za.exe" a -t7z -r "%OUTFILE%.7z" "*.*"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

attrib +R "%OUTFILE%.7z"

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Clean up
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

popd

rmdir /Q /S "%PACK_PATH%" 2> NUL

echo.
echo PACKAGE COMPLETED.
echo.

pause
