##### CONFIG HERE ####################

$servicename = "CheckMKAgent"
$port = 6556

$autoupdatelocation = "\\server\share\checkmk-agent\"
$autoupdate = $false
$autoupdateinterval = 60  # minutes


# Monitoring | Eventlog : Ignore these eventlogs
$global:eventlog_ignorelog = @("Operations Manager")