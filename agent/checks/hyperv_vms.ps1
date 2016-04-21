Function prestart()
{
}

#public enum VMState : int  
#{
#                    Paused = 32768,
#                  Stopped = 3,
#                   Running = 2,
#                    Saving = 32773,
#                  Stopping = 32774,
#              Snapshotting = 32771,
#                 Suspended = 32769,
#                  Starting = 32770 
#}
#$HyperVNamespace                      = "root\virtualization"

Function run2008r2() {
	if ((Get-WmiObject -Namespace root -class __NAMESPACE -filter "name='virtualization'") -eq $null) { return }
		
	Send-Line "<<<hyperv_vms>>>"
	gwmi -Namespace "root\virtualization" -Query "SELECT * FROM MSVM_Computersystem WHERE Description='Microsoft Virtual Machine'" |% {
		switch ($_.EnabledState) {
			"2" { $state="Running" }
			"3" { $state="Stopped" }
			"32768" { $state="Paused" }
			"32773" { $state="Saving" }
			"32774" { $state="Stopping" }
			"32771" { $state="Snapshotting" }
			"32769" { $state="Suspended" }
			"32770" { $state="Starting" }
			default { $state="Unknown" }
		}
		$uptime = "00:00:00"
		#$uptime = (Get-Date) - ($_.TimeOfLastStateChange)
		#write-host $_.ElementName $state $uptime $_.StatusDescriptions[0]
		Send-Line ($_.ElementName+" "+$state+" "+$uptime+" "+$_.StatusDescriptions[0])
	}
}

Function run2012() {
	if ((Get-WmiObject -Namespace root -class __NAMESPACE -filter "name='virtualization'") -eq $null) { return }
	
	Send-Line "<<<hyperv_vms>>>"
	Get-VM | format-table -HideTableHeaders -property Name, State, Uptime, Status
}

Function run()
{
	$os = [System.Environment]::OSVersion.Version
	if ($os.Major -eq 6 -and $os.Minor -eq 1) {
		run2008r2		
	}
	if ($os.Major -eq 6 -and $os.Minor -gt 1) {
		run2012
	}
	if ($os.Major -gt 6) {
		run2012
	}
}

Function terminate()
{
}
