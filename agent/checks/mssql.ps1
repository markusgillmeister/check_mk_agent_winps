Function run()
{
	try 
	{
	
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

		$out_mssql_versions = ""
		$out_mssql_tablespaces = ""
		$out_mssql_backup = ""
		$hasMSSQL = $false
		
		$captions = gwmi win32_service | ?{$_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe"} | %{$_.Caption}
		foreach ($caption in $captions) {
			$hasMSSQL = $true
		
			$instance = $caption | %{$_.split(" ")[-1]} | %{$_.trimStart("(")} | %{$_.trimEnd(")")}
			$tmp_instance = $instance
			if ($instance -eq "MSSQLSERVER") { 
				
				#$tmp_instance = "default"
				$instance="localhost"
			} else { 
				#$tmp_instance = $instance
				$instance ="localhost\" + $instance 
			}
			$srv = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server -argumentList $instance
			
			$out_mssql_versions += $tmp_instance + " " + $srv.Information.VersionString + "`r`n"

			$srv.Databases |% { 
				# IsMirroringEnabled   False True
				# MirroringStatus  Synchronized
				# LastBackupDate 
				# SpaceAvailable 1584
				# Size 5,25
				# DataSpaceUsage 1136
				# IndexSpaceUsage 1048
				
				$backupdate = ""
				$dbname = $_.Name
				
				if ($_.IsMirroringEnabled -eq $false -or ($_.IsMirroringEnabled -eq $true -and $_.Status -eq "Normal")) {
					# not mirrored db or this is the active mirror
					$totalpages = 0.0
					$tempdsn = "Server = $instance; Database = " + $_.Name + "; Integrated Security = True"
					$sqlsource = New-Object Data.SqlClient.SqlConnection($tempdsn)
					$sqlda = New-Object System.Data.SqlClient.SqlDataAdapter ("select ltrim(str(SUM(total_pages) * 8192 / 1024.,15,0)) from sys.allocation_units",$sqlsource)
					$sqlds = New-Object System.Data.DataSet
					try {
						$sqlda.Fill($sqlds) |% {  # "Rows count: " + $_
						}
					} catch {}
					$sqlds |% {
						$totalpages = @($_.Tables[0])[0][0]
					}
					$sqlsource.Close()					
			
					$dbsize    = ([string] $_.Size) + " MB " 
					$availsize = ([string] [System.Math]::Round(($_.SpaceAvailable/1024), 2)) + " MB "
					$reservesize = ([string] $totalpages) + " KB "
					$datasize  =  ([string] $_.DataSpaceUsage) + " KB "
					$logsize   =  ([string] $_.IndexSpaceUsage) + " KB "
					$unused0 = $totalpages - $_.DataSpaceUsage - $_.IndexSpaceUsage
					$unused  =  ([string] $unused0) + " KB"

					$backupdate = Get-Date $_.LastBackupDate -format "yyyy-MM-dd HH:mm:ss"
					if ($backupdate -eq "0001-01-01 00:00:00") {
						$backupdate = "1970-01-01 00:00:00"
					}					

				} else {
					# mirrored db 
					$mirrorpartner = $_.MirroringPartnerInstance
										
					$srv2 = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server -argumentList $mirrorpartner
					$mirrordb = $srv2.Databases | Where { $_.Name -eq $dbname }

					$totalpages = 0.0
					$tempdsn = "Server = " + $mirrorpartner + "; Database = " + $dbname + "; Integrated Security = True"
					$sqlsource = New-Object Data.SqlClient.SqlConnection($tempdsn)
					$sqlda = New-Object System.Data.SqlClient.SqlDataAdapter ("select ltrim(str(SUM(total_pages) * 8192 / 1024.,15,0)) from sys.allocation_units",$sqlsource)
					$sqlds = New-Object System.Data.DataSet
					try {
						$sqlda.Fill($sqlds) |% {  # "Rows count: " + $_
						}
					} catch {}
					$sqlds |% {
						$totalpages = @($_.Tables[0])[0][0]
					}
					$sqlsource.Close()					
			
					$dbsize    = ([string] $mirrordb.Size) + " MB " 
					$availsize = ([string] [System.Math]::Round(($mirrordb.SpaceAvailable/1024), 2)) + " MB "
					$reservesize = ([string] $totalpages) + " KB "
					$datasize  =  ([string] $mirrordb.DataSpaceUsage) + " KB "
					$logsize   =  ([string] $mirrordb.IndexSpaceUsage) + " KB "
					$unused0 = $totalpages - $mirrordb.DataSpaceUsage - $mirrordb.IndexSpaceUsage
					$unused  =  ([string] $unused0) + " KB"

					$backupdate = Get-Date $mirrordb.LastBackupDate -format "yyyy-MM-dd HH:mm:ss"
					if ($backupdate -eq "0001-01-01 00:00:00") {
						$backupdate = "1970-01-01 00:00:00"
					}		
				}

				if ($backupdate -ne "" -and $_.Name -ne "tempdb") { 
					$out_mssql_backup      += $tmp_instance + " " + $_.Name + " " + $backupdate + "`r`n"
				}

				$out_mssql_tablespaces += $tmp_instance + " " + $dbname + " " + $dbsize + $availsize + $reservesize + $datasize + $logsize + $unused + "`r`n"
			}	
		}
		
		if ($hasMSSQL -eq $true) {
			Send-Line "<<<mssql_versions>>>"
			Send-Line $out_mssql_versions
			Send-Line "<<<mssql_tablespaces>>>"
			Send-Line $out_mssql_tablespaces
			Send-Line "<<<mssql_backup>>>"
			Send-Line $out_mssql_backup
		} 

	} catch {
		#Send-Line "<<<debug>>>"
		#Send-Line $_.Exception.Message 
	}
}