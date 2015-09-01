Function prestart()
{
}

Function run()
{
    $avg_disk_queue = "1166"
    $avg_disk_read_queue = "1168"
    $avg_disk_write_queue = "1170"
    $disk_read_sec = "-20"
    $disk_write_sec = "-18"
    $disk_readbyte_sec = "-14"
    $disk_writebyte_sec = "-12"
    $instancecount = 0
    $instance = " instances:"

    gwmi Win32_PerfRawData_PerfDisk_PhysicalDisk |% {
        $instance += " " + $_.Name.Replace(" ","_")
        $instancecount++

        $avg_disk_queue       += " " + $_.AvgDiskQueueLength
        $avg_disk_read_queue  += " " + $_.AvgDiskReadQueueLength
        $avg_disk_write_queue += " " + $_.AvgDiskWriteQueueLength
        $disk_read_sec        += " " + $_.DiskReadsPersec
        $disk_write_sec       += " " + $_.DiskWritesPersec
        $disk_readbyte_sec    += " " + $_.DiskReadBytesPersec
        $disk_writebyte_sec   += " " + $_.DiskWriteBytesPersec
    }
    Send-Line ""
    Send-Line "<<<winperf_phydisk>>>"
    $unixtime=[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    Send-Line ([string]$unixtime + " 234")
    Send-Line ([string]$instancecount + $instance)
    Send-Line ($avg_disk_queue + " type(550500)")
    Send-Line ($avg_disk_read_queue + " type(550500)")
    Send-Line ($avg_disk_write_queue + " type(550500)") 
    Send-Line ($disk_read_sec + " counter")
    Send-Line ($disk_write_sec + " counter")
    Send-Line ($disk_readbyte_sec + " bulk_count")
    Send-Line ($disk_writebyte_sec + " bulk_count")

}

Function terminate()
{
}
