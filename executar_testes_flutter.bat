@echo off
title Testes Unitarios Flutter
echo ========================================================
echo   Executando 13 Testes Unitarios e de Integracao
echo ========================================================
echo.
cd /d "%~dp0\vini_somativa dia 11 - Copia"
flutter test -r expanded
echo.
echo ========================================================
pause
