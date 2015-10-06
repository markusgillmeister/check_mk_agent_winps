# +------------------------------------------------------------------+
# |                   CHECK MK agent for Windows                     |
# | (c) Markus Gillmeister 2014            markus.gillmeister@lrz.de |
# +------------------------------------------------------------------+
#      Agent is licensed under GNU LESSER GENERAL PUBLIC LICENSE

Write-Host "Doing autoupgrade..."

# locate script directory
[string]$BASEDIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASEDIR += "\"
$CHECKDIR = $BASEDIR + "checks\"
$COMPDIR = $BASEDIR + "components\"
$TOOLSDIR = $BASEDIR + "tools\"
$STATEDIR = $BASEDIR + "state\"

. $BASEDIR\config.ps1

# test reachability of updatelocation

if (Test-Path ($autoupdatelocation + "checkmkagent.ps1")) {
	# File Share is accessible
	$au_checks = $autoupdatelocation + "checks\"
	$au_comp = $autoupdatelocation + "components\"
	$au_tools = $autoupdatelocation + "tools\"
	$versionfile = $autoupdatelocation + "version.txt"
	$currversionfile = $BASEDIR + "version.txt"
	
	Start-Sleep -Seconds 2
	
	Remove-Item $CHECKDIR -Force -Recurse
	Remove-Item $COMPDIR -Force -Recurse
	Remove-Item $TOOLSDIR -Force -Recurse
	Remove-Item ($BASEDIR + "checkmkagent.ps1") -Force
	Remove-Item ($BASEDIR + "install.ps1") -Force  #legacy
	Remove-Item ($BASEDIR + "uninstall.ps1") -Force #legacy 
	Remove-Item ($BASEDIR + "service-install.ps1") -Force
	Remove-Item ($BASEDIR + "service-uninstall.ps1") -Force
	Remove-Item ($BASEDIR + "config.ps1") -Force
	
	Copy-Item $au_checks $CHECKDIR -force -recurse
	Copy-Item $au_comp $COMPDIR -force -recurse
	Copy-Item $au_tools $TOOLSDIR -Force -Recurse
	Copy-Item ($autoupdatelocation + "checkmkagent.ps1") ($BASEDIR + "checkmkagent.ps1") -Force
	Copy-Item ($autoupdatelocation + "service-install.ps1") ($BASEDIR + "service-install.ps1") -Force
	Copy-Item ($autoupdatelocation + "service-uninstall.ps1") ($BASEDIR + "service-uninstall.ps1") -Force
	Copy-Item ($autoupdatelocation + "config.ps1") ($BASEDIR + "config.ps1") -Force
	Copy-Item ($autoupdatelocation + "autoupgrade.ps1") ($BASEDIR + "autoupgrade2.ps1") -Force
	Copy-Item $versionfile $currversionfile -force
	
	Write-Host "Upgrade done."
	Exit	

} else {
	# Update not possible. 
	Write-Host "Upgrade not possible - fileshare not available"
	Exit
}
