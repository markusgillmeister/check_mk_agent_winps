
function run() {
	if ((Get-WmiObject -Namespace root -class __NAMESPACE -filter "name='MicrosoftDFS'") -eq $false) { return }

	Send-Line "<<<dfs>>>"

	$RGroups = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query "SELECT * FROM DfsrReplicationGroupConfig"
	$ComputerName=$env:ComputerName
	$Succ=0
	$Warn=0
	$Err=0
	 
	foreach ($Group in $RGroups)
	{
	    $RGFoldersWMIQ = "SELECT * FROM DfsrReplicatedFolderConfig WHERE ReplicationGroupGUID='" + $Group.ReplicationGroupGUID + "'"
	    $RGFolders = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query  $RGFoldersWMIQ
	    $RGConnectionsWMIQ = "SELECT * FROM DfsrConnectionConfig WHERE ReplicationGroupGUID='"+ $Group.ReplicationGroupGUID + "'"
	    $RGConnections = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query  $RGConnectionsWMIQ
	    foreach ($Connection in $RGConnections)
	    {
	        $ConnectionName = $Connection.PartnerName.Trim()
	        if ($Connection.Enabled -eq $True)
	        {
	           if (((New-Object System.Net.NetworkInformation.ping).send("$ConnectionName")).Status -eq "Success")
	           {
	                foreach ($Folder in $RGFolders)
	                {
	                    $RGName = $Group.ReplicationGroupName
	                    $RFName = $Folder.ReplicatedFolderName
	 
	                    if ($Connection.Inbound -eq $True)
	                    {
	                        $SendingMember = $ConnectionName
	                        $ReceivingMember = $ComputerName
	                        $Direction="inbound"
	                    }
	                    else
	                    {
	                        $SendingMember = $ComputerName
	                        $ReceivingMember = $ConnectionName
	                        $Direction="outbound"
	                    }
	 
	                    $BLCommand = "dfsrdiag Backlog /RGName:'" + $RGName + "' /RFName:'" + $RFName + "' /SendingMember:" + $SendingMember + " /ReceivingMember:" + $ReceivingMember
	                    $Backlog = Invoke-Expression -Command $BLCommand
	 
	                    $BackLogFilecount = 0
	                    foreach ($item in $Backlog)
	                    {
	                        if ($item -ilike "*Backlog File count*")
	                        {
	                            $BacklogFileCount = [int]$Item.Split(":")[1].Trim()
	                        }
	                    }
	 
	                    if ($BacklogFileCount -eq 0)
	                    {
	                        $Color="white"
	                        $Succ=$Succ+1
	                    }
	                    elseif ($BacklogFilecount -lt 10)
	                    {
	                        $Color="yellow"
	                        $Warn=$Warn+1
	                    }
	                    else
	                    {
	                        $Color="red"
	                        $Err=$Err+1
	                    }
	                    Write-Host "$BacklogFileCount files in backlog $SendingMember->$ReceivingMember for $RGName" -fore $Color
	 
	                } # Closing iterate through all folders
	           } # Closing  If replies to ping
	        } # Closing  If Connection enabled
	    } # Closing iteration through all connections
	} # Closing iteration through all groups
	Write-Host "$Succ successful, $Warn warnings and $Err errors from $($Succ+$Warn+$Err) replications."
}


