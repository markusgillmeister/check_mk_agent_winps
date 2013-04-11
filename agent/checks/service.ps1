Function run()
{
	Send-Line "<<<services>>>"
	$temp=""
	gwmi Win32_Service | select DisplayName,Name,Started,StartMode |% {
		if ($_.Started -eq $true) {
			$tstarted = "running"
		} else {
			$tstarted = "stopped"
		}
		$temp+= ($_.Name -replace " ","_") + " " + $tstarted  + "/" + ($_.StartMode).ToLower() + " " + $_.DisplayName + "`r`n"
	}
	Send-Line $temp
}