Function prestart()
{
}

Function run()
{
	$statfile = $STATEDIR + "stat_windows_updates.log"
	if ((LogRefreshNeeded $statfile 3600) -eq $true) {
		$file = "`"" + $COMPDIR + "windows_updates.vbs`""
		#Invoke-Expression "cscript //Nologo $file"  | Out-File $statfile
		Start-Process "cscript" -ArgumentList "//Nologo $file" -RedirectStandardOutput $statfile
	}
	
	Send-Line "<<<windows_updates>>>"
	Send-Line (Get-Content $statfile)
}

Function terminate()
{
}