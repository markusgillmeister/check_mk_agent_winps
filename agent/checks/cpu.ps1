Function run()
{
	Send-Line "<<<winperf_processor>>>"
	$unixtime=[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
	Send-Line $unixtime
	$temp = "-232"
	gwmi Win32_PerfRawData_PerfOS_Processor | select PercentProcessorTime |% { $temp += " " + $_.PercentProcessorTime % ([math]::pow(2,32)) }
	$temp += " 100nsec_timer_inv"
	Send-Line $temp
}