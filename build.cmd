@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Read configuration
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set MSYS2_DIR=
set JAVA_HOME=
set ANT_HOME=
set PANDOC_DIR=

if not exist "%~dp0.\build.cfg" (
	echo Configuration file "build.cfg" not found. Please create^^!
	pause
	goto:eof
)

for /F "usebackq tokens=1,* delims==" %%a in ("%~dp0.\build.cfg") do (
	set "%%~a=%%~b"
)

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Verify paths
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if not exist "%MSYS2_DIR%\msys2_shell.cmd" (
	echo MSYS2 SHELL not found. Please check MSYS2_DIR and try again^^!
	pause
	goto:eof
)

if not exist "%JAVA_HOME%\bin\java.exe" (
	echo Java not found. Please check JAVA_HOME and try again^^!
	pause
	goto:eof
)

if not exist "%ANT_HOME%\bin\ant.bat" (
	echo Ant not found. Please check ANT_HOME and try again^^!
	pause
	goto:eof
)

if not exist "%PANDOC_DIR%\pandoc.exe" (
	echo Pandoc not found. Please check PANDOC_DIR and try again^^!
	pause
	goto:eof
)

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Build!
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo ========================================================================
echo Clean
echo ========================================================================
echo.
call "%MSYS2_DIR%\msys2_shell.cmd" -mingw32 -no-start -defterm -where "%~dp0" -c "make clean"
echo.

for %%m in (32,64) do (
	echo ========================================================================
	echo Build %%m-Bit
	echo ========================================================================
	echo.
	call "%MSYS2_DIR%\msys2_shell.cmd" -mingw%%m -no-start -defterm -where "%~dp0" -c "make -B"
	if not "!ERRORLEVEL!"=="0" goto:BuildHasFailed
	echo.
)

echo ========================================================================
echo Build example
echo ========================================================================
echo.
set "PATH=%ANT_HOME%\bin;%JAVA_HOME%\bin;%PATH%"
call "%ANT_HOME%\bin\ant.bat" -f "%~dp0.\src\example\build.xml"
echo.

echo ========================================================================
echo Generate docs
echo ========================================================================
echo.
echo "%~dp0.\README.md" --^> "%~dp0.\README.html"
"%PANDOC_DIR%\pandoc.exe" --verbose -f markdown-implicit_figures -t html5 --standalone --ascii --toc --toc-depth=2 --css="etc/css/gh-pandoc.css" -o "%~dp0.\README.html" "%~dp0.\README.yaml" "%~dp0.\README.md"
echo.

echo.
echo BUILD COMPLETED.
echo.

if not "%MAKE_NONINTERACTIVE%"=="1" pause
exit /B 0

REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM Failed
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:BuildHasFailed

echo.
echo BUILD HAS FAILED ^^!^^!^^!
echo.

if not "%MAKE_NONINTERACTIVE%"=="1" pause
exit /B 1
