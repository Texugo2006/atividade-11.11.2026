@echo off
title Subir Projeto para GitHub
echo ========================================================
echo   Enviando projeto para o repositorio do GitHub
echo   https://github.com/Texugo2006/atividade-11.11.2026.git
echo ========================================================
echo.
cd /d "%~dp0"
git push -u origin main
echo.
echo ========================================================
echo   Concluido! Pressione qualquer tecla para fechar.
echo ========================================================
pause
