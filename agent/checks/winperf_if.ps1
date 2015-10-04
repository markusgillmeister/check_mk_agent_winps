Function prestart()
{
}

function run() {

	Send-Line "<<<winperf_if>>>"
	$unixtime=[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
	Send-Line ($unixtime + " 510")
	
	$i = 0
	$lines = @{}
	$lines[0] = "instances: SPACE"
	$lines[1] = "-122 SPACE bulk_count"
	$lines[2] = "-110 SPACE bulk_count"
	$lines[3] = "-244 SPACE  bulk_count"
	$lines[4] = "-58 SPACE bulk_count"
	$lines[5] = "10 SPACE large_rawcount" # Bandwidth
	$lines[6] = "-246 SPACE bulk_count"	# ifInOctets
	$lines[7] = "14 SPACE bulk_count"	# inucast 
	$lines[8] = "16 SPACE bulk_count" # non-unicast empfangen
	$lines[9] = "18 SPACE large_rawcount" # ifInDiscards
	$lines[10] = "20 SPACE large_rawcount" # ifInErrors
	$lines[11] = "22 SPACE large_rawcount" # 
	$lines[12] = "-4 SPACE bulk_count" # ifOutOctets (Bytes gesendet)
	$lines[13] = "26 SPACE bulk_count" # outucast
	$lines[14] = "28 SPACE bulk_count" # outnonucast
	$lines[15] = "30 SPACE large_rawcount" # ifOutDiscards
	$lines[16] = "32 SPACE large_rawcount" # ifOutErrors
	$lines[17] = "34 SPACE large_rawcount" # ifOutQLen
	$lines[18] = "1086 SPACE large_rawcount" # 
	gwmi Win32_PerfRawData_Tcpip_NetworkInterface |% {
		$i++
		$lines[0] = $lines[0].REPLACE("SPACE",$_.Name.Replace(" ","_") + " SPACE")
		$lines[1] = $lines[1].REPLACE("SPACE","0 SPACE")
		$lines[2] = $lines[2].REPLACE("SPACE","0 SPACE")
		$lines[3] = $lines[3].REPLACE("SPACE","0 SPACE")
		$lines[4] = $lines[4].REPLACE("SPACE","0 SPACE")
		$lines[5] = $lines[5].REPLACE("SPACE",([string]$_.CurrentBandwidth) + " SPACE")
		$lines[6] = $lines[6].REPLACE("SPACE",([string]$_.PacketsReceivedPersec) + " SPACE")
		$lines[7] = $lines[7].REPLACE("SPACE",([string]$_.PacketsReceivedUnicastPersec) + " SPACE")
		$lines[8] = $lines[8].REPLACE("SPACE",([string]$_.PacketsReceivedNonUnicastPersec) + " SPACE")
		$lines[9] = $lines[9].REPLACE("SPACE",([string]$_.PacketsReceivedDiscarded) + " SPACE")
		$lines[10] = $lines[10].REPLACE("SPACE",([string]$_.PacketsReceivedErrors) + " SPACE")
		$lines[11] = $lines[11].REPLACE("SPACE","0 SPACE")
		$lines[12] = $lines[12].REPLACE("SPACE",([string]$_.PacketsSentPersec) + " SPACE")
		$lines[13] = $lines[13].REPLACE("SPACE",([string]$_.PacketsSentUnicastPersec) + " SPACE")
		$lines[14] = $lines[14].REPLACE("SPACE",([string]$_.PacketsSentNonUnicastPersec) + " SPACE")
		$lines[15] = $lines[15].REPLACE("SPACE",([string]$_.PacketsOutboundDiscarded) + " SPACE")
		$lines[16] = $lines[16].REPLACE("SPACE",([string]$_.PacketsOutboundErrors) + " SPACE")
		$lines[17] = $lines[17].REPLACE("SPACE",([string]$_.OutputQueueLength) + " SPACE")
		$lines[18] = $lines[18].REPLACE("SPACE","0 SPACE")
	}
	
	$lines[0] = ([string]$i) + " " + $lines[0]
		
	for  ($j=0; $j -le 18; $j++) {
		Send-Line ($lines[$j].Replace("SPACE",""))
	}

	send-line "<<<winperf_if:sep(44)>>>"
	$ret = gwmi Win32_NetworkAdapter | select SystemName,MACAddress,Name,NetConnectionID,NetConnectionStatus | ConvertTo-Csv -NoTypeInformation
	send-line $ret
}

Function terminate()
{
}