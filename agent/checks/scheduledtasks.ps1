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
		$ScheduledTasks | Where-Object { $_ -ne $null } |% {
			$name = $_.Name  -replace " ","_"
			$lastruntime = $_.lastruntime -replace " ","_"
			$nextruntime = $_.nextruntime -replace " ","_"
			$lastresult = $_.LastTaskResult 
			# -2147216609 = Es wird bereits eine Instanz des Tasks ausgeführt
			$xml = [xml]$_.Xml
			$user=""
			if ($xml.Task.Principals.Principal.UserId -eq $null) {
				$user = $xml.Task.Principals.Principal.GroupId
			} else {
				$user = $xml.Task.Principals.Principal.UserId
			}
			$user = $user.Replace("\","/")
			Send-Line ($name + " " + $_.enabled + " " + $lastruntime + " " + $nextruntime + " " + $lastresult + " " + $_.NumberOfMissedRuns + " " + $user)
		}
	}
}

Function terminate()
{
}