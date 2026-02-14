@echo off
:: Recompilation rapide de Xpolaris-Windows-Customizer.exe
:: Lance le script de recompilation avec droits admin

title Recompilation Xpolaris-Windows-Customizer.exe

:: Vérifier si admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo Demande de droits administrateur...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: Lancer le script de recompilation
cd /d "%~dp0"
cls
echo.
echo ═══════════════════════════════════════════════════════
echo   RECOMPILATION DE L'EXÉCUTABLE XPOLARIS
echo ═══════════════════════════════════════════════════════
echo.
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Recompile-Exe.ps1"

echo.
pause
