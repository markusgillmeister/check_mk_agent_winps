@echo off


sc stop CheckMKAgent

rmdir "c:\Program Files\Check_MK" /S /Q

xcopy /K /R /E /I /S /C /H /Y \\DOMAINSHARE\Check_MK\Check_MK "c:\Program Files\Check_MK\"

sc start CheckMKAgent

