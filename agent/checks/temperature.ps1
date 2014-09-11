Function prestart()
{
	$env:CheckMKstateDir = $STATEDIR
	& ($COMPDIR + 'coretemp\Core Temp.exe')
}

Function run()
{
	Send-Line "<<<temperature>>>"
	$statfile = $STATEDIR + "coretemp.log"
	Send-Line (Get-Content $statfile)
}

Function terminate()
{
	taskkill /IM "Core Temp.exe" /F
}