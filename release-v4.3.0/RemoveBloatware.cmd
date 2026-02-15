@echo off
REM ============================================================
REM Remove Bloatware - Launcher
REM Lance le script PowerShell avec ExecutionPolicy Bypass
REM ============================================================

echo.
echo ============================================
echo   SUPPRESSION BLOATWARE WINDOWS 11
echo   Xpolaris OS - Post-Installation
echo ============================================
echo.

REM Verifier les droits administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Vous devez executer ce script en tant qu'administrateur
    echo Faites un clic droit et choisissez "Executer en tant qu'administrateur"
    pause
    exit /b 1
)

REM Verifier si le script existe
if not exist "%~dp0RemoveBloatware.ps1" (
    echo [ERREUR] RemoveBloatware.ps1 introuvable
    echo Verifiez que le fichier est dans le meme dossier
    pause
    exit /b 1
)

REM Lancer le script PowerShell avec ExecutionPolicy Bypass
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0RemoveBloatware.ps1"

echo.
pause
