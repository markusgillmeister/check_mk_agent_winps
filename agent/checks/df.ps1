Function run()
{
	Send-Line "<<<df>>>"
	$temp=""
	gwmi Win32_LogicalDisk -Filter "DriveType=3" | select DeviceId,FileSystem,Size,FreeSpace |% { $temp += $_.DeviceId + " " + $_.FileSystem + " " + ($_.Size/1024) + " " + (($_.Size-$_.FreeSpace)/1024) + " " + ($_.FreeSpace/1024) + " " + [System.Math]::Round( (($_.Size-$_.FreeSpace)/$_.Size)*100 , 2) + "% " + $_.DeviceId + "`r`n" }
	Send-Line $temp
}