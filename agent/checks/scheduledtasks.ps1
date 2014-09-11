Function prestart()
{
}

Function run()
{
	if ($isDeprecatedOS -eq $false) {
		Send-Line "<<<scheduled_task>>>"
		$ST = new-object -com("Schedule.Service")
		$ST.connect()
		$RootFolder = $ST.getfolder("\")
		$ScheduledTasks = $RootFolder.GetTasks(0)
		$ScheduledTasks |% {
			$name = $_.Name  -replace " ","_"
			$lastruntime = $_.lastruntime -replace " ","_"
			$nextruntime = $_.nextruntime -replace " ","_"
			$lastresult = $_.LastTaskResult 
			# -2147216609 = Es wird bereits eine Instanz des Tasks ausgeführt
			$xml = [xml]$_.Xml
			$user = $xml.Task.Principals.Principal.UserId.Replace("\","/")
			Send-Line ($name + " " + $_.enabled + " " + $lastruntime + " " + $nextruntime + " " + $lastresult + " " + $_.NumberOfMissedRuns + " " + $user)
		}
	}
}

Function terminate()
{
}