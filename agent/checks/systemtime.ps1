Function prestart()
{
}

Function run() 
{
	$EpochDiff = New-TimeSpan "01 January 1970 00:00:00" $((Get-Date).ToUniversalTime())
	$EpochSecs = [INT] $EpochDiff.TotalSeconds
	Send-Line "<<<systemtime>>>"
	Send-Line $EpochSecs
}

Function terminate()
{
}