@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "MSYS2_DIR=C:\msys64"

if not exist "%MSYS2_DIR%\msys2_shell.cmd" (
	echo MSYS2 SHELL not found. Please check MSYS2_DIR and try again^^!
	pause
	goto:eof
)

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
	call "%MSYS2_DIR%\msys2_shell.cmd" -mingw%%m -no-start -defterm -where "%~dp0" -c "make -B -j8"
	if not "!ERRORLEVEL!"=="0" goto:build_completed
	echo.
)

echo ALL IS DONE.

:build_completed
pause
