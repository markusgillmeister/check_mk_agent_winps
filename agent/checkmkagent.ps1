# +------------------------------------------------------------------+
# |                   CHECK MK agent for Windows                     |
# | (c) Markus Gillmeister 2014            markus.gillmeister@lrz.de |
# +------------------------------------------------------------------+
#      Agent is licensed under GNU LESSER GENERAL PUBLIC LICENSE

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

$WmiOS = Get-WMIObject -class Win32_OperatingSystem
$WmiCS = Get-WMIObject -class Win32_ComputerSystem
$psinfo = get-host
$psversion = $psinfo.Version.Major

[console]::TreatControlCAsInput = $true

$encoding = new-object System.Text.AsciiEncoding
$endpoint = new-object System.Net.IpEndpoint ([System.Net.Ipaddress]::any,$port)
$listener = new-object System.Net.Sockets.TcpListener $endpoint
$client = New-Object System.Net.Sockets.TcpClient

$isServer = $false
$isDeprecatedOS = $false
$isVM = $false
$psversion = $PSVersionTable.PSVersion.Major

if ($WmiOS.Caption -like "*Server*") {
	$isServer = $true
}
if ($WmiOS.Caption -like "*2003*") {
	$isDeprecatedOS = $true
}
if ($isServer -eq $true -and $isDeprecatedOS -eq $false) {
	Import-Module servermanager
}
if ($WmiCS.Manufacturer -like "*VMWare*" -or $WmiCS.Manufacturer -like "*Microsoft*" -or $WmiCS.Manufacturer -like "*Xen*") {
	$isVM = $true
}

if (Test-Path ($BASEDIR + "autoupgrade2.ps1")) {
  # new autoupdate file
  Move-Item ($BASEDIR + "autoupgrade2.ps1") ($BASEDIR + "autoupgrade.ps1") -force
}

$starttime = Get-Date

Function ConvertWMIDateToDateTime($ctime)
{
	[System.Management.ManagementDateTimeconverter]::ToDateTime($ctime)
}

Function LogRefreshNeeded 
{
	param([string]$LogFileName,[int]$MaxMinutes)

	if ((Test-Path $LogFileName) -eq $false) { return $true }

	$fdate = (ls $LogFileName).LastWriteTime
	$timeDiff = New-TimeSpan $fdate (Get-Date)
	if ($timeDiff.TotalMinutes -gt $MaxMinutes) {
		return $true
	} else {
		return $false
	}
}

Function Touch-File
{
		param ([string]$LogFileName)
		if($LogFileName -eq $null) {
		    throw "No filename supplied"
		}
		if(Test-Path $LogFileName)
		{
		    Set-ItemProperty -Path $LogFileName -Name LastWriteTime -Value (get-date)
		}
		else
		{
		    Set-Content -Path ($LogFileName) -Value ($null);
		}
}


Function Run-Prestart()
{
    $Dir = get-childitem $CHECKDIR
    $List = $Dir | where {$_.extension -eq ".ps1"}
    $List | select name |% { 
        $file = $CHECKDIR + $_.Name
        . $file 

		prestart
    }
}

Function Run-Terminate()
{
    $Dir = get-childitem $CHECKDIR
    $List = $Dir | where {$_.extension -eq ".ps1"}
    $List | select name |% { 
        $file = $CHECKDIR + $_.Name
        . $file 

		terminate
    }
}


Function Run-Check()
{
    $Dir = get-childitem $CHECKDIR
    $List = $Dir | where {$_.extension -eq ".ps1"}
    $List | select name |% { 
        $file = $CHECKDIR + $_.Name
        . $file 
		# is needed due to refresh
		$WmiOS = Get-WMIObject -class Win32_OperatingSystem
		$WmiCS = Get-WMIObject -class Win32_ComputerSystem
		
		run
    }
}

Function Check-Update($manualcheck = $false) 
{
	try {
		if ($autoupdate -eq $true) {
			# auto-update enabled				
			if ( ((Get-Date) - $starttime).Minutes -gt $autoupdateinterval -or $manualcheck -eq $true) {
				# recheck-interval reached or manual update triggered
				$starttime = Get-Date
				$versionfile = $autoupdatelocation + "version.txt"
				$currversionfile = $BASEDIR + "version.txt"
				if (Test-Path $versionfile){
					# version file on server found
					$compare = Compare-Object -ReferenceObject (Get-Content $currversionfile) -DifferenceObject (Get-Content $versionfile)
					if ($compare.Count -gt 1) {
						# difference to our version, update has to be done
						Run-Terminate  # terminate checks
						Start-Sleep -Seconds 2

						#$startInfo = New-Object System.Diagnostics.ProcessStartInfo
						#$startInfo.FileName = "powershell.exe"
						#$startInfo.Arguments = $BASEDIR + "autoupgrade.ps1"

						$newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
						$newProcess.WorkingDirectory = $BASEDIR
						$newProcess.Arguments = $BASEDIR + "autoupgrade.ps1"
						$newProcess.Verb = "runas"
						[System.Diagnostics.Process]::Start($newProcess);

						try {
							$socket.close()
						} catch [Exception] {
						}
						$listener.stop()
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")						
						Exit
					}
				} else {
					Write-Host "Update location not found"
				}
				
			}
		}
	} catch [Exception] {
		Write-Host "Update function failed"
	}
}

Function Start-Server() 
{
	try {
		$listener.start()
	} catch [Exception] {
		Write-Host "cannot open socket"
		Write-Host $_.Exception.Message
		exit		
	}

	Run-Prestart
	
	while ($true)
	{
		Check-Update
		
		while (-not $listener.Pending())
		{
			Start-Sleep -m 100
			if ([console]::KeyAvailable)
			{
				$key = [system.console]::readkey($true)
				if ((($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) -or $key.key -eq "E")
				{
					"Terminating..."
					Run-Terminate
					try {
						$socket.close()
					} catch [Exception] {
					}
					$listener.stop()
					Exit
				}
				if ($key.key -eq "U") {
					Check-Update $true
				}
			}
		}
		$socket = $listener.AcceptTcpClient()  # will block here until connection
		$networkstream = $socket.GetStream()
		$networkbuffer = New-Object System.Byte[] $socket.ReceiveBufferSize
	
		Run-Check
		
		$socket.close()
	}
	$listener.stop()	
}

Function Send-Line($line) 
{
	if ($line -is [Array]) {
		for ($i=0;$i -lt $line.Count; $i++) {
			Send-Line-Helper $line[$i]
		}		
	} else {
		Send-Line-Helper $line
	}
}

Function Send-Line-Helper([string]$line) 
{
		#debug write-host $line
		$line = $line.Trim() + "`r`n"
		$networkstream.Write($encoding.GetBytes($line),0,$line.Length)		
}

Start-Server
