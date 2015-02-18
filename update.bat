@echo off
c:
cd \  

sc stop CheckMKAgent
sc delete CheckMKAgent

rem temporarily when upgrading from older agent


rmdir "%PROGRAMFILES%\Check_MK" /S /Q
taskkill /F /IM "Core Temp.exe" /T

rem install.bat

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
