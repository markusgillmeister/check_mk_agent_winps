Function prestart()
{
}

Function run()
{
	$statfile = $STATEDIR + "stat_windows_updates.log"
	
	# Send state file if it exists and has content
	if ((Test-Path $statfile) -and (Get-Item $statfile).Length -gt 0) {
		Send-Line "<<<windows_updates>>>"
		Send-Line (Get-Content $statfile)
	}	
	
	if ((LogRefreshNeeded $statfile 60) -eq $true) {
		# if logfile does not exist create empty file , so that following check runs do not overrun each other
		# TODO: This is probably not needed anymore, since Start-Process below immediately nulls the file
		if ((Test-Path $statfile) -eq $false) { 
			New-Item -ItemType file $statfile 
		}
		
		# Check for Windows updates in the background
		$file = "`"" + $COMPDIR + "windows_updates.vbs`""
		Start-Process "cscript" -ArgumentList "//Nologo $file" -RedirectStandardOutput $statfile
	}
}

Function terminate()
{
	$statfile = $STATEDIR + "stat_windows_updates.log"
	if (Test-Path $statfile) { Remove-Item $statfile }
}
