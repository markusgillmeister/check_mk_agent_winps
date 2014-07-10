Function run()
{
	Send-Line "<<<df>>>"
	$temp=""
	gwmi Win32_Volume -Filter "DriveType=3" | select Caption,DriveLetter,Label,FileSystem,Capacity,FreeSpace |% { 
		$label = $_.Caption
		if ($_.Label -ne $null) {
			$label = $_.Label -replace " ",""
		}
		if ($_.DriveLetter -ne $null) {
			$label = $_.DriveLetter
		}
		$temp += $label + " " + $_.FileSystem + " " + ($_.Capacity/1024) + " " + (($_.Capacity-$_.FreeSpace)/1024) + " " + ($_.FreeSpace/1024) + " " + [System.Math]::Round( (($_.Capacity-$_.FreeSpace)/$_.Capacity)*100 , 2) + "% " + $label + "`r`n" 	
	}
	Send-Line $temp
}