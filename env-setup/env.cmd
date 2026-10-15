@echo off
rem Временное окружение для текущей сессии cmd (без изменения системного PATH).
if "%LABENV_DIR%"=="" set "LABENV_DIR=C:\labenv"
set "PATH=%LABENV_DIR%\mingw64\bin;%PATH%"
g++ --version | findstr /n "g++"
