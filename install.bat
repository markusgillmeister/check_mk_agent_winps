@echo off
c:
cd \

echo Copy over agent
xcopy /K /R /E /I /S /C /H /Y /Q %~dp0\agent "%PROGRAMFILES%\Check_MK\"
rem via domain xcopy /K /R /E /I /S /C /H /Y /Q \\DOMAINSHARE\Check_MK\Check_MK "%PROGRAMFILES%\Check_MK\"

cd "%PROGRAMFILES%\Check_MK\"

echo Installing service
powershell "& .\service-install.ps1"

echo Optional open Firewall
rem tools\open-firewall.cmd

echo Trying to start service...
net start CheckMKAgent
