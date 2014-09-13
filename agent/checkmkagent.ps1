# +------------------------------------------------------------------+
# |                   CHECK MK agent for Windows                     |
# | (c) Markus Gillmeister 2014            markus.gillmeister@lrz.de |
# +------------------------------------------------------------------+
#      Agent is licensed under GNU LESSER GENERAL PUBLIC LICENSE


# 
# Press  STRG+C to quit agent in console mode

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
						
						$au_checks = $autoupdatelocation + "checks\"
						$au_comp = $autoupdatelocation + "components\"
						Run-Terminate  # terminate checks
						Start-Sleep -Seconds 2
						Remove-Item $CHECKDIR -Force -Recurse
						Remove-Item $COMPDIR -Force -Recurse
						Copy-Item $au_checks $CHECKDIR -force -recurse
						Copy-Item $au_comp $COMPDIR -force -recurse
						#xcopy /K /R /E /I /S /C /H /Y $au_checks $CHECKDIR
						#xcopy /K /R /E /I /S /C /H /Y $au_comp $COMPDIR
						#xcopy /Y $versionfile .\version.txt
						Copy-Item $versionfile $currversionfile -force
						Run-Prestart # warmup checks
						
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
		write-host $line
		$line = $line.Trim() + "`r`n"
		$networkstream.Write($encoding.GetBytes($line),0,$line.Length)		
}

Start-Server
