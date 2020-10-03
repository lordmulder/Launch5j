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

set "OUTFILE=%~dp0.\out\launch5j-bin.%ISO_DATE%.zip"

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Clean-up
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir "%~dp0.\out" 2> NUL
del /F "%OUTFILE%" 2> NUL

if exist "%OUTFILE%" (
	echo Failed to delete existing "%OUTFILE%" file!
	pause
	goto:eof
)

set "PACK_PATH=%~dp0.\out\~package%RANDOM%"
rmdir /Q /S "%PACK_PATH%" 2> NUL

if exist "%PACK_PATH%" (
	echo Failed to delete existing "%PACK_PATH%" directory!
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

mkdir "%PACK_PATH%"
mkdir "%PACK_PATH%\x64"
mkdir "%PACK_PATH%\etc"
mkdir "%PACK_PATH%\etc\img"
mkdir "%PACK_PATH%\etc\style"
mkdir "%PACK_PATH%\example"

copy /Y "%~dp0.\*.txt"                   "%PACK_PATH%"
copy /Y "%~dp0.\*.html"                  "%PACK_PATH%"
copy /Y "%~dp0.\bin\launch5j_x86*.exe"   "%PACK_PATH%"
copy /Y "%~dp0.\bin\launch5j_amd64*.exe" "%PACK_PATH%\x64"
copy /Y "%~dp0.\etc\style\*.css"         "%PACK_PATH%\etc\style"
copy /Y "%~dp0.\etc\img\*.png"           "%PACK_PATH%\etc\img"

copy /Y /B "%~dp0.\bin\launch5j_x86_wrapped_registry.exe" + "%~dp0.\src\example\dist\example.jar" "%PACK_PATH%\example\example.exe"
copy /Y "%~dp0.\src\example\src\com\muldersoft\l5j\example\Main.java" "%PACK_PATH%\example\example.java"

attrib +R "%PACK_PATH%\*.*" /S

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Create ZIP package
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pushd "%PACK_PATH%"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

echo ========================================================================
echo Creating ZIP
echo ========================================================================
echo.
"%~dp0.\etc\utils\info-zip\zip.exe" -r -9 "%OUTFILE%" "*.*"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

popd

rmdir /Q /S "%PACK_PATH%" 2> NUL
attrib +R "%OUTFILE%"

echo.
echo PACKAGE COMPLETED.
echo.

pause
