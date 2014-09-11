Function prestart()
{
}

Function run()
{
	Send-Line "<<<ps>>>"
	Get-Process |% {
		Send-Line ($_.ProcessName)
	}
}

Function terminate()
{
}