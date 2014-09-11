Function prestart()
{
}

Function run() 
{
	if ($WmiCS.domainrole -eq 4 -or $WmiCS.domainrole -eq 5) {
	Send-Line "<<<ad_replication>>>"
	$ret = Invoke-Expression "repadmin /showrepl /csv"
	Send-Line $ret
	}
}

Function terminate()
{
}