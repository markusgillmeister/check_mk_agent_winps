@echo off

xcopy /K /R /E /I /S /C /H /Y \\DOMAINSHARE\Check_MK\Check_MK "c:\Program Files\Check_MK\"

echo Installing service...
rem sc create CheckMKAgent BinPath= "\"C:\Program Files\Check_MK\service\Check_MKAgent.exe\"" type= own start= auto DisplayName= "Check_MK Agent"

cd "c:\Program Files\Check_MK\"
powershell "install.ps1"


echo Trying to start service...
rem sc start CheckMKAgent
sc start CheckMKAgent
