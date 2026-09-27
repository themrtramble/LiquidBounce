@echo off
setlocal EnableDelayedExpansion
title LiquidBounce Boosted - Launcher
color 0B

echo ============================================================
echo   LiquidBounce Boosted - Game Launcher
echo ============================================================
echo.

:: Refresh boosted JAR first (in case launcher overwrote it)
echo [STEP 1] Refreshing boosted JAR...
call "%LOCALAPPDATA%\LiquidBounceBoosted\refresh-boosted.bat"
echo.

:: Find LiquidLauncher
set "LAUNCHER_PATH=%LOCALAPPDATA%\Programs\LiquidLauncher\LiquidLauncher.exe"
set "LAUNCHER_PATH2=%PROGRAMFILES%\LiquidLauncher\LiquidLauncher.exe"

if exist "%LAUNCHER_PATH%" (
    echo [STEP 2] Launching LiquidLauncher...
    echo [INFO] Path: %LAUNCHER_PATH%
    start "" "%LAUNCHER_PATH%"
) else if exist "%LAUNCHER_PATH2%" (
    echo [STEP 2] Launching LiquidLauncher...
    echo [INFO] Path: %LAUNCHER_PATH2%
    start "" "%LAUNCHER_PATH2%"
) else (
    echo [WARN] LiquidLauncher.exe not found at expected locations.
    echo [INFO] Looked at:
    echo   - %LAUNCHER_PATH%
    echo   - %LAUNCHER_PATH2%
    echo.
    echo [INFO] Please launch LiquidLauncher manually from Start Menu.
    echo.
)

echo ============================================================
echo   Done! LiquidLauncher should now open.
echo   Click PLAY to start LiquidBounce with boosted KillAura.
echo ============================================================
echo.
timeout /t 3 >nul
exit /b 0
