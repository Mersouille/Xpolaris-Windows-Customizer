@echo off
REM ===================================================================
REM Lanceur pour Xpolaris-Apps-Manager.ps1
REM Lance le script avec elevation admin et politique d'execution debloquee
REM ===================================================================

title Xpolaris Apps Manager
echo.
echo ========================================
echo   XPOLARIS APPS MANAGER
echo   Lancement en cours...
echo ========================================
echo.

REM Lancer PowerShell avec elevation admin et politique Bypass
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "& {Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"%~dp0Xpolaris-Apps-Manager.ps1\"' -Verb RunAs}"

echo.
echo Script termine.
timeout /t 3 /nobreak >nul
