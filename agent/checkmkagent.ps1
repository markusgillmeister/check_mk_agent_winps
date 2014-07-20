# +------------------------------------------------------------------+
# |                   CHECK MK agent for Windows                     |
# | (c) Markus Gillmeister 2013            markus.gillmeister@lrz.de |
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

if ($WmiOS.Caption -like "*Server*") {
	$isServer = $true
}
if ($WmiOS.Caption -like "*2003*") {
	$isDeprecatedOS = $true
}
if ($isServer -eq $true -and $isDeprecatedOS -eq $false) {
	Import-Module servermanager
}



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

Function Start-Server() 
{
	try {
		$listener.start()
	} catch [Exception] {
		Write-Host "cannot open socket"
		Write-Host $_.Exception.Message
		exit		
	}

	while ($true)
	{
		while (-not $listener.Pending())
		{
			Start-Sleep -m 100
			if ([console]::KeyAvailable)
			{
				$key = [system.console]::readkey($true)
				if (($key.modifiers -band [consolemodifiers]"control") -and	($key.key -eq "C"))
				{
					"Terminating..."
					try {
						$socket.close()
					} catch [Exception] {
					}
					$listener.stop()
					Exit
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
