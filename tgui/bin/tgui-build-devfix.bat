@echo off
cd "%~dp0\.."
call yarn install
call yarn run build-fix
timeout /t 600
