Function prestart()
{
}

Function run()
{
	$statfile = $STATEDIR + "stat_windows_updates.log"
	if ((LogRefreshNeeded $statfile 3600) -eq $true) {
		#if logfile does not exist create empty file , so that following check runs do not overrun each other
		if ((Test-Path $statfile) -eq $false) { 
			"0 0 0" | Out-File $statfile 
		}
		
		$file = "`"" + $COMPDIR + "windows_updates.vbs`""
		#Invoke-Expression "cscript //Nologo $file"  | Out-File $statfile
		Start-Process "cscript" -ArgumentList "//Nologo $file" -RedirectStandardOutput $statfile
	}
	
	Send-Line "<<<windows_updates>>>"
	Send-Line (Get-Content $statfile)
}

Function terminate()
{
	$statfile = $STATEDIR + "stat_windows_updates.log"
	if (Test-Path $statfile) { Remove-Item $statfile }
}