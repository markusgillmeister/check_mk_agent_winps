Function prestart()
{
	if ($isVM -eq $false) {
		$env:CheckMKstateDir = $STATEDIR
		& ($COMPDIR + 'OpenHardwareMonitor\OpenHardwareMonitor.exe')
	}
}

Function run()
{
	if ($isVM -eq $false) {
		Send-Line "<<<temperature>>>"
		$t = gwmi -Class Sensor -Namespace root\OpenHardwareMonitor -Filter "SensorType='Temperature'" | select Name,Value
		$t |% {
			Send-Line ($_.Name + " " + $_.Value)
		}
		# $statfile = $STATEDIR + "coretemp.log"
		# Send-Line (Get-Content $statfile)
	}
}

Function terminate()
{
	if ($isVM -eq $false) {
		taskkill /IM "OpenHardwareMonitor.exe" /F
	}
}