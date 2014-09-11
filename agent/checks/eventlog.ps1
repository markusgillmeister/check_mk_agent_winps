Function prestart()
{
}

Function run()
{
	Send-Line "<<<logwatch>>>"
	
	Get-EventLog -list |% {
		# cycle trough all event logs
	  $logname = $_.Log
	  $logstat = $STATEDIR + "event_" + $logname + ".log"
	  
	  Send-Line ("[[[" + $logname + "]]]")

		if (Test-Path $logstat) {
			# eventlog already seen
			$index = Get-Content $logstat
		} else {
			# eventlog new
			$index = 0
		}

		$currentmaxindex = (Get-EventLog -LogName $logname -Newest 1 -ErrorAction "SilentlyContinue").Index
		if ($currentmaxindex -lt $index -or $currentmaxindex -eq $null) {
			# index roll-over
			$index = 0
		}
		
		Get-EventLog -LogName $logname -newest 100 -ErrorAction "SilentlyContinue" | Where-Object { $_.Index -gt $index } |% {
			# $_.EntryType  Warning  Information Error

			$newindex = $_.Index

			# FIRST STEP: only send Warnings and errors without further parsing!
			# TODO: improvement
			if ($_.EntryType -eq "Warning") {
				Send-Line ("W " + $_.TimeGenerated + " " + $_.Source + " " + $_.Message)
			}
			if ($_.EntryType -eq "Error") {
				Send-Line ("C " + $_.TimeGenerated + " " + $_.Source + " " + $_.Message)
			}
		}
		
		#write new index position
		$newindex | Out-File $logstat
	}

}

Function terminate()
{
}