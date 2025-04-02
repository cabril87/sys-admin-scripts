# Check-DiskUsage.ps1
# A simple script to check and display disk usage information on Windows.

# You can adjust the warning threshold here (percentage used).
$warningThreshold = 80

# Get all fixed drives (DriveType = 3 means fixed drive)
$drives = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"

foreach ($drive in $drives) {
    # Calculate the drive usage
    $totalSizeGB  = [math]::Round($drive.Size / 1GB, 2)
    $freeSpaceGB  = [math]::Round($drive.FreeSpace / 1GB, 2)
    $usedSpaceGB  = $totalSizeGB - $freeSpaceGB
    $percentUsed  = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
    $percentFree  = 100 - $percentUsed

    Write-Host "Drive $($drive.DeviceID)"
    Write-Host "  Total Size : $totalSizeGB GB"
    Write-Host "  Free Space : $freeSpaceGB GB"
    Write-Host "  Used Space : $usedSpaceGB GB ($percentUsed% used, $percentFree% free)"

    # Check if the usage exceeds our threshold
    if ($percentUsed -ge $warningThreshold) {
        Write-Warning "  WARNING: Drive usage is above $warningThreshold%!"
    }
    Write-Host  # Blank line for readability
}
