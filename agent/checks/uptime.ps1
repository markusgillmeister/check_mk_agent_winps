Function prestart()
{
}

Function run()
{
		$BootTime = $WmiOS.LastBootUpTime
		$LastBootUpTime = ConvertWMIDateToDateTime($BootTime)
		$Uptime = (Get-Date) - $lastBootUpTime

		$days = $Uptime.Days
		$hours = $Uptime.Hours
		$min = $uptime.Minutes
		$sec = $uptime.Seconds
		$total = $days * 86400 + $hours * 3600 + $min * 60 + $sec

		Send-Line "<<<uptime>>>"
		Send-Line $total
}

Function terminate()
{
}