Function prestart()
{
}

Function run()
{
	$version = Get-Content ($BASEDIR + "version.txt")
	Send-Line "<<<check_mk>>>"
	Send-Line ("Version: " + $version)
	Send-Line "AgentOS: windows"
	Send-Line ("Hostname: " + $WmiOS.CSName)
	Send-Line "WorkingDirectory: $BASEDIR"
	Send-Line "ConfigFile: config.ps1"
	Send-Line "AgentDirectory: $BASEDIR"
	Send-Line "PluginsDirectory: $CHECKDIR"
	Send-Line "LocalDirectory: -"
	Send-Line "OnlyFrom: 0.0.0.0/0, controlled via windows firewall"
}

Function terminate()
{
}
