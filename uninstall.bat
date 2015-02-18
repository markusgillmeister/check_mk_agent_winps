@echo off
c:
cd "%PROGRAMFILES%\Check_MK"

powershell "& .\service-uninstall.ps1"
cd \

rmdir "%PROGRAMFILES%\Check_MK" /S /Q
