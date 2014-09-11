Function prestart()
{
}

Function run() 
{
	$net = netstat -ano | Select-String -Pattern '\s+(TCP|UDP)'

	$state_ESTABLISHED=0
	$state_SYN_SENT=0
	$state_SYN_RECV=0
	$state_LAST_ACK=0
	$state_CLOSE_WAIT=0
	$state_TIME_WAIT=0
	$state_CLOSED=0
	$state_CLOSING=0
	$state_FIN_WAIT1=0
	$state_FIN_WAIT2=0

	$net |% {
		$entry = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) 
		switch ($entry[3]) {
			"HERGESTELLT" { $state_ESTABLISHED++ }
			"WARTEND" { $state_TIME_WAIT++ }
			"SCHLIESSEN_WARTEN" { $state_CLOSE_WAIT++ } 
			
			"ESTABLISHED" { $state_ESTABLISHED++ }
			"SYN_SEND" { $state_SYN_SENT++ }
			"SYN_RECEIVED" { $state_SYN_RECV++ }
			"LAST_ACK" { $state_LAST_ACK++ }
			"CLOSE_WAIT" { $state_CLOSE_WAIT++ }
			"TIME_WAIT" { $state_TIME_WAIT++ }
			"CLOSED" { $state_CLOSED++ }
			"CLOSING" { $state_CLOSING++ }		
			"FIN_WAIT_1" { $state_FIN_WAIT1++ }
			"FIN_WAIT_2" { $state_FIN_WAIT2++ }
		}
	}
	 
	send-line "<<<tcp_conn_stats>>>"
	send-line ("ESTABLISHED " + $state_ESTABLISHED)
	send-line ("SYN_SENT " + $state_SYN_SENT)
	send-line ("SYN_RECV " + $state_SYN_RECV)
	send-line ("LAST_ACK " + $state_LAST_ACK)
	send-line ("CLOSE_WAIT " + $state_CLOSE_WAIT)
	send-line ("TIME_WAIT " + $state_TIME_WAIT)
	send-line ("CLOSED " + $state_CLOSED)
	send-line ("CLOSING " + $state_CLOSING)
	send-line ("FIN_WAIT1 " + $state_FIN_WAIT1)
	send-line ("FIN_WAIT2 " + $state_FIN_WAIT2)
}

Function terminate()
{
}