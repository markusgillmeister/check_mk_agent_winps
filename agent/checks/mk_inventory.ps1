Function prestart()
{
}

Function outputWMI($headline,$wmi,$seperator=":") {
	if ($headline -ne $null) { Send-Line $headline }
	$wmi | Get-Member | where { $_.MemberType -eq "NoteProperty" } |% { Send-Line ($_.Name + $seperator + $wmi.($_.Name)) }
}


Function run()
{
	$statfile = $STATEDIR + "stat_mk_inventory.log"
	$maxminutes = 3600
	
	if ((LogRefreshNeeded $statfile $maxminutes) -eq $true) {
		Touch-File $statfile
	
		# calculate unix timestamp
		$epoch=[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
		# convert it to integer and add $delay seconds plus 5 minutes
		$until = [int]($epoch -replace ",.*", "") + ($maxminutes*60) + 600	

		# Processor
		Send-Line "<<<win_cpuinfo:sep(58):persist($until)>>>"
		gwmi -Class "Win32_Processor" | select Name,Manufacturer,Caption,DeviceID,MaxClockSpeed,AddressWidth,L2CacheSize,L3CacheSize,Architecture,NumberOfCores,NumberOfLogicalProcessors,CurrentVoltage,Status |% {
			outputWMI $null $_ ":"
		}

		# OS Version
		#write-host "<<<win_os:sep(124):persist($until)>>>"
		$os = $WmiOS | select Caption,CSDVersion,OSArchitecture,Version,WindowsDirectory,OSLanguage,RegisteredUser,Organization,ServicePackMajorVersion,ServicePackMinorVersion,@{Label="InstallDate";Expression={$_.ConvertToDateTime($_.InstallDate)}},@{Label="LastBootUpTime";Expression={$_.ConvertToDateTime($_.LastBootUpTime)}}
		outputWMI "<<<win_os:sep(58):persist($until)>>>" $os ":"
		
		# BIOS
		$bios = gwmi -Class "Win32_Bios" | select SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion,Manufacturer,Name,SerialNumber,Version
		outputWMI "<<<win_bios:sep(58):persist($until)>>>" $bios ":"
		
		# System
		$system = gwmi Win32_SystemEnclosure | Select Manufacturer,Model,LockPresent,SerialNumber,SMBIOSAssetTag,SecurityStatus
		outputWMI "<<<win_system:sep(58):persist($until)>>>" $system ":"

		# Hard-Disk
		# BUG  Size makes trouble in CheckMK  -> array["size"] = int(value)    with  size = 299433093120
		Send-Line "<<<win_disks:sep(58):persist($until)>>>"
		gwmi -Class "Win32_DiskDrive" | Select "Manufacturer","InterfaceType","Model","Name","SerialNumber","Size","MediaType","Signature" |% {
			outputWMI $null $_ ":"
		}
		
		# Graphics Adapter
		Send-Line "<<<win_video:sep(58):persist($until)>>>" 
		gwmi Win32_VideoController | Select Name,Description,AdapterCompatibility,VideoModeDescription,VideoProcessor,DriverVersion,DriverDate,MaxMemorySupported |% {
			outputWMI $null $gpu ":"
		}
		
	}
}

Function terminate()
{
	$statfile = $STATEDIR + "stat_mk_inventory.log"
	if (Test-Path $statfile) { Remove-Item $statfile }
}