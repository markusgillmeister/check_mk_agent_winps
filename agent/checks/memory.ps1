Function run()
{
	Send-Line "<<<mem>>>"
	Send-Line ("MemTotal:      " + ($WmiCS.TotalPhysicalMemory/1024) + " kB")
	Send-Line ("MemFree:       " + $WmiOS.FreePhysicalMemory + " kB")
	Send-Line ("SwapTotal:     " + ($WmiOS.TotalVirtualMemorySize - ($WmiCS.TotalPhysicalMemory/1024)) + " kB")
	Send-Line ("SwapFree:      " + $WmiOS.FreeSpaceInPagingFiles + " kB")
	Send-Line ("PageTotal:     " + $WmiOS.TotalVirtualMemorySize + " kB")
	Send-Line ("PageFree:      " + $WmiOS.FreeVirtualMemory + " kB")

}