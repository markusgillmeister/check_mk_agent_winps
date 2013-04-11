Function run()
{
	Send-Line "<<<check_mk>>>"
	Send-Line "Version: 2.0.1ps"
	Send-Line "AgentOS: windows"
	Send-Line ("Hostname: " + $WmiOS.CSName)
	Send-Line "WorkingDirectory: $BASEDIR"
	Send-Line "ConfigFile: -"
	Send-Line "AgentDirectory: $BASEDIR"
	Send-Line "PluginsDirectory: $CHECKDIR"
	Send-Line "LocalDirectory: -"
	Send-Line "OnlyFrom: 0.0.0.0/0"
}
