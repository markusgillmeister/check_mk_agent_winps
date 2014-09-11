Function prestart()
{
}

function run() {

send-line "<<<winperf_if:sep(44)>>>"
$ret = gwmi Win32_NetworkAdapter | select SystemName,MACAddress,Name,NetConnectionID,NetConnectionStatus | ConvertTo-Csv -NoTypeInformation
send-line $ret
}

Function terminate()
{
}