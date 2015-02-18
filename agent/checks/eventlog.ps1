Function prestart()
{
}

Function run()
{
	Send-Line "<<<logwatch>>>"
  Get-EventLog -list | Where-Object { $_.Log -notin $global:eventlog_ignorelog } |% {
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

		$newindex = 0		
		Get-EventLog -LogName $logname -newest 100 -ErrorAction "SilentlyContinue" | Where-Object { $_.Index -gt $index } |% {
			# $_.EntryType  Warning  Information Error

			if ($_.Index -gt $newindex) {
				$newindex = $_.Index
			}
			
			
			#Filter
			
			#IGNORES
			$ignore = $false
			if ($_.EventID -eq 1530 -and $_.Source -eq "Microsoft-Windows-User Profiles Service") { $ignore = $true }
			if ($_.EventID -eq 63 -and $_.Source -eq "WinMgmt") { $ignore = $true }
			if ($_.EventID -eq 20070 -and $_.Source -eq "OpsMgr Connector") { $ignore = $true }
			if ($_.EventID -eq 1200 -and $_.Source -eq "Check_MKAgent") { $ignore = $true }
			if ($_.EventID -eq 16385 -and $_.Source -eq "Software Protection Platform Service") { $ignore = $true }
			if ($_.EventID -eq 10 -and $_.Source -eq "WinMgmt") { $ignore = $true }
			if ($_.EventID -eq 5807 -and $_.Source -eq "NETLOGON") { $ignore = $true } # don't map to any of the existing sites in the enterprise
			if ($_.EventID -eq 29 -and $_.Source -eq "KDC") { $ignore = $true } # The Key Distribution Center (KDC) cannot find a suitable certificate
			if ($_.EventID -eq 1021 -and $_.Source -eq "Perflib") { $ignore = $true } # The local computer may not have the necessary registry information or message DLL fi
			if ($_.EventID -eq 2887 -and $_.Source -eq "NTDS")  { $ignore = $true } # Some clients attempted to perform LDAP binds that were either: (1) A SASL
			
			switch ($_.EntryType)
			{
					"Error"   { $entrytype="C" }
					"Warning" { $entrytype="W" }
#					"Information" { $entrytype="I" }
					default   { $entrytype="" }
			}
			
#5002 DFSR  ->Err  (error in communication)
#5014 DFSR  ->Warn (stopped)
#5004 DFSR  ->Info (gutmeldung)
#
#Replacement Strings: 
# Connection ID,
# partner
# share
# dfs error (1726 remote procedure failed)
# replication group id
 		
			if ($ignore -eq $false -and $entrytype -ne "") {
				Send-Line ($entrytype + " " + $_.TimeGenerated + " ID:" + $_.EventID + " Source:" + $_.Source + " Msg:" + $_.Message.Replace("`n"," "))
			}
			
		}
		
		#write new index position
		if ($newindex -ne 0) {
			$newindex | Out-File $logstat
		}
	}

}

Function terminate()
{
}