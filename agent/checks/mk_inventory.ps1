Function prestart()
{
}

Function outputWMI($headline,$wmi,$seperator=":") {
	Send-Line $headline
	$wmi | Get-Member | where { $_.MemberType -eq "NoteProperty" } |% { Send-Line ($_.Name + $seperator + $wmi.($_.Name)) }
}


Function run()
{
	$statfile = $STATEDIR + "stat_mk_inventory.log"
	$maxminutes = 3600
	
	if ((LogRefreshNeeded $statfile ) -eq $true) {
		Touch-File $statfile
	
		# calculate unix timestamp
		$epoch=[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
		# convert it to integer and add $delay seconds plus 5 minutes
		$until = [int]($epoch -replace ",.*", "") + ($maxminutes*60) + 600	

		# Processor
		$processor = gwmi -Class "Win32_Processor" | select DeviceID,Architecture,Description,Manufacturer,MaxClockSpeed,Name,SocketDesignation
		outputWMI "<<<win_cpuinfo:sep(58):persist($until)>>>" $processor ":"

		# OS Version
		#write-host "<<<win_os:sep(124):persist($until)>>>"
		$os = $WmiOS | select Caption,CSDVersion,OSArchitecture,Version,WindowsDirectory,OSLanguage,RegisteredUser,Organization,@{Label="InstallDate";Expression={$_.ConvertToDateTime($_.InstallDate)}},@{Label="LastBootUpTime";Expression={$_.ConvertToDateTime($_.LastBootUpTime)}}
		outputWMI "<<<win_os:sep(58):persist($until)>>>" $os ":"
		
		# BIOS
		$bios = gwmi -Class "Win32_Bios" | select SMBIOSBIOSVersion,Manufacturer,Name,SerialNumber,Version
		outputWMI "<<<win_bios:sep(58):persist($until)>>>" $bios ":"
		
		# System
		$system = gwmi Win32_SystemEnclosure | Select Manufacturer,Model,LockPresent,SerialNumber,SMBIOSAssetTag,SecurityStatus
		outputWMI "<<<win_system:sep(58):persist($until)>>>" $system ":"

		# Hard-Disk
		$physicaldisk= gwmi -Class "Win32_DiskDrive" | Select Model,Partitions,FirmwareRevision,SerialNumber,@{Name="Size(GB)";Expression={"{0:N1}" -f($_.Size/1gb)}}
		outputWMI "<<<win_disks:sep(58):persist($until)>>>" $physicaldisk ":"

		# Graphics Adapter
		$gpu=gwmi Win32_VideoController | Select Name,Description,AdapterCompatibility,VideoModeDescription,VideoProcessor,DriverVersion,DriverDate,MaxMemorySupported
		outputWMI "<<<win_video:sep(58):persist($until)>>>" $gpu ":"
	}
}

Function terminate()
{
	$statfile = $STATEDIR + "stat_mk_inventory.log"
	if (Test-Path $statfile) { Remove-Item $statfile }
}