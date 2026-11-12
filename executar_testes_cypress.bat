@echo off
title Testes E2E Cypress
echo ========================================================
echo   Executando Testes E2E Web com Cypress
echo ========================================================
echo.
cd /d "%~dp0\vini_somativa dia 11 - Copia"
npx cypress run
echo.
echo ========================================================
pause
