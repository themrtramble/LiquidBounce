@echo off
setlocal EnableDelayedExpansion
title LiquidBounce Boosted - Refresh
color 0B

echo ============================================================
echo   LiquidBounce Boosted - Refresh Utility
echo   Re-applies boosted JAR if LiquidLauncher overwrote it
echo ============================================================
echo.

:: Detect mods folder
set "LIQUID_LAUNCHER=%APPDATA%\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods"
set "DEFAULT_MC=%APPDATA%\.minecraft\mods"

if exist "%LIQUID_LAUNCHER%" (
    set "MODS_FOLDER=%LIQUID_LAUNCHER%"
    echo [INFO] Detected LiquidLauncher mods folder.
) else if exist "%DEFAULT_MC%" (
    set "MODS_FOLDER=%DEFAULT_MC%"
    echo [INFO] Detected default .minecraft mods folder.
) else (
    echo [ERROR] No mods folder found!
    echo Expected one of:
    echo   %LIQUID_LAUNCHER%
    echo   %DEFAULT_MC%
    echo.
    pause
    exit /b 1
)

echo [INFO] Mods folder: %MODS_FOLDER%
echo.

:: Make sure folder exists
if not exist "%MODS_FOLDER%" (
    mkdir "%MODS_FOLDER%"
)

:: Backup existing jar if not already backed up
if exist "%MODS_FOLDER%\LiquidBounce.jar" (
    if not exist "%MODS_FOLDER%\LiquidBounce-official-backup.jar" (
        echo [BACKUP] Saving official LiquidBounce.jar...
        copy /Y "%MODS_FOLDER%\LiquidBounce.jar" "%MODS_FOLDER%\LiquidBounce-official-backup.jar" >nul
        if !ERRORLEVEL! EQU 0 (
            echo [OK] Backup created: LiquidBounce-official-backup.jar
        ) else (
            echo [WARN] Could not backup. Continuing anyway.
        )
    ) else (
        echo [SKIP] Backup already exists.
    )
) else (
    echo [INFO] No existing LiquidBounce.jar found.
)

:: Copy boosted JAR over LiquidBounce.jar
echo [APPLY] Copying boosted JAR to LiquidBounce.jar...
copy /Y "%LOCALAPPDATA%\LiquidBounceBoosted\liquidbounce-boosted.jar" "%MODS_FOLDER%\LiquidBounce.jar" >nul

if %ERRORLEVEL% EQU 0 (
    echo [OK] Boosted LiquidBounce.jar applied successfully!
    echo.
    echo ============================================================
    echo   SUCCESS! Boosted KillAura is now active.
    echo ============================================================
    echo.
    echo Location: %MODS_FOLDER%\LiquidBounce.jar
    echo.
    echo NOTE: If LiquidLauncher replaces it again, just run this
    echo       "Refresh" shortcut before launching the game.
    echo.
    echo Tip: Disable auto-update in LiquidLauncher settings to
    echo      prevent the launcher from overwriting this JAR.
    echo.
) else (
    echo [ERROR] Failed to copy JAR!
    echo Try running this script as Administrator.
    echo.
)

timeout /t 5 >nul
exit /b 0
