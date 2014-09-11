@echo off

xcopy /K /R /E /I /S /C /H /Y \\DOMAINSHARE\Check_MK\Check_MK "c:\Program Files\Check_MK\"

echo Installing service...
sc create CheckMKAgent BinPath= "\"C:\Program Files\Check_MK\service\Check_MKAgent.exe\"" type= own start= auto DisplayName= "Check_MK Agent"

echo Trying to start service...
sc start CheckMKAgent

