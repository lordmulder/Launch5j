@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "PANDOC_DIR=C:\Program Files (x86)\Pandoc"

if not exist "%PANDOC_DIR%\pandoc.exe" (
	echo Pandoc not found. Please check PANDOC_DIR and try again^^!
	pause
	goto:eof
)

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Get current date
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set "ISO_DATE="

for /F "usebackq tokens=1" %%a in (`start /WAIT /B "" "%~dp0.\etc\utils\win32\core-utils\date.exe" +"%%Y-%%m-%%d"`) do (
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

rmdir /Q /S "%~dp0.\out\~package" 2> NUL

if exist "%~dp0.\out\~package" (
	echo Failed to delete existing "%~dp0.\out\~package" directory!
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

mkdir "%~dp0.\out\~package"
mkdir "%~dp0.\out\~package\x64"

copy /Y "%~dp0.\bin\launch5j_x86*.exe" "%~dp0.\out\~package"
copy /Y "%~dp0.\bin\launch5j_x64*.exe" "%~dp0.\out\~package\x64"

mkdir "%~dp0.\out\~package\etc"
mkdir "%~dp0.\out\~package\etc\example"
mkdir "%~dp0.\out\~package\etc\img"

copy /Y "%~dp0.\*.txt" "%~dp0.\out\~package"
copy /Y "%~dp0.\etc\img\*.png" "%~dp0.\out\~package\etc\img"

copy /Y /B "%~dp0.\bin\launch5j_x86_wrapped_registry.exe" + "%~dp0.\etc\example\dist\example.jar" "%~dp0.\out\~package\etc\example\example.exe"
copy /Y "%~dp0.\etc\example\src\com\muldersoft\l5j\example\Main.java" "%~dp0.\out\~package\etc\example\example.java"

"%PANDOC_DIR%\pandoc.exe" -f markdown-implicit_figures -t html -T "Launch5j" --toc "%~dp0.\README.md" > "%~dp0.\out\~package\README.html"

attrib +R "%~dp0.\out\~package\*.*" /S

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Create ZIP package
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pushd "%~dp0.\out\~package"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

echo ========================================================================
echo Creating ZIP
echo ========================================================================
echo.
"%~dp0.\etc\utils\win32\info-zip\zip.exe" -r -9 "%OUTFILE%" "*.*"

if not "%ERRORLEVEL%"=="0" (
	pause
	goto:eof
)

popd

rmdir /Q /S "%~dp0.\out\~package" 2> NUL

attrib +R "%OUTFILE%"

echo.
echo PACKAGE COMPLETED.
echo.

pause
