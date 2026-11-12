@echo off
title Servidor Mock - json-server :3000
echo ========================================================
echo   Iniciando API RESTful Mock (db.json na porta 3000)
echo ========================================================
echo.
cd /d "%~dp0\vini_somativa dia 11 - Copia"
npx json-server --watch db.json --port 3000
pause
