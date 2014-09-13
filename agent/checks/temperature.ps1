Function prestart()
{
	if ($isVM -eq $false) {
		$env:CheckMKstateDir = $STATEDIR
		& ($COMPDIR + 'coretemp\Core Temp.exe')
	}
}

Function run()
{
	if ($isVM -eq $false) {
		Send-Line "<<<temperature>>>"
		$statfile = $STATEDIR + "coretemp.log"
		Send-Line (Get-Content $statfile)
	}
}

Function terminate()
{
	if ($isVM -eq $false) {
		taskkill /IM "Core Temp.exe" /F
	}
}