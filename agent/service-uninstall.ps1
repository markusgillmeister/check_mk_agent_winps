# +------------------------------------------------------------------+
# |                   CHECK MK agent for Windows                     |
# | (c) Markus Gillmeister 2014            markus.gillmeister@lrz.de |
# +------------------------------------------------------------------+
#      Agent is licensed under GNU LESSER GENERAL PUBLIC LICENSE

# 
# Press  STRG+C to quit agent in console mode

# Check if we running as administrator, otherwise switch over to admin console
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
## Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
## Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole) -eq $false) {
	## We are not running "as Administrator" - so relaunch as administrator
	## Create a new process object that starts PowerShell
	$newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
	## Specify the current script path and name as a parameter
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	## Indicate that the process should be elevated
	$newProcess.Verb = "runas";
	## Start the new process
	[System.Diagnostics.Process]::Start($newProcess);
	## Exit from the current, unelevated, process
	Exit
}

# locate script directory
[string]$BASEDIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASEDIR += "\"
$CHECKDIR = $BASEDIR + "checks\"
$COMPDIR = $BASEDIR + "components\"
$STATEDIR = $BASEDIR + "state\"

. $BASEDIR\config.ps1

cd $BASEDIR

.\nssm.exe stop $servicename
.\nssm.exe remove $servicename confirm