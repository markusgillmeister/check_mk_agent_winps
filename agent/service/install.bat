@echo off

echo.
echo Please run this command with elevated administrative privileges.
echo Otherwise this service installation will fail.
echo.
echo Enter the directory where the powershell-script is located.
echo Example: c:\my\agent\  (with trailing backslash)
echo Note: This script will also set the path in Check_MKAgent.exe.config
echo.
set /p bpath=Enter Path: 
echo.

cd /d %~dp0

(
for /f "tokens=1,* delims=]" %%A in ('"type Check_MKAgent.exe.config.sample|find /n /v """') do (
set "line=%%B"
if defined line (
    call set "line=echo.%%line:WORKINGDIR=%bpath%%%"
    for /f "delims=" %%X in ('"echo."%%line%%""') do %%~X
    ) ELSE echo.
)
)>Check_MKAgent.exe.config

echo Installing service...
sc create CheckMKAgent BinPath= "%bpath%service\Check_MKAgent.exe" type= own start= auto DisplayName= "CheckMK Agent"

echo Trying to start service...
sc start CheckMKAgent

echo.
pause

