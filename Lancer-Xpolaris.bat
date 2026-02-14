@echo off
:: Lanceur Windows Customizer by Xpolaris
:: Necessite les droits administrateur

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Demande des droits administrateur...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo Lancement de Windows Customizer...
powershell -ExecutionPolicy Bypass -NoProfile -File "Xpolaris-GUI.ps1"
if %errorLevel% neq 0 pause
