<#
.SYNOPSIS
    Collects system information (OS, CPU, memory) and saves it to a timestamped file.

.DESCRIPTION
    Gathers basic system details using CIM instances and writes them to a text file in the
    user's Documents\SysAdminReports directory. Includes error handling and user feedback.

.PARAMETER OutputDir
    Specifies the directory to save the report. Defaults to Documents\SysAdminReports.

.EXAMPLE
    .\system_info.ps1
    Runs with default output directory.

.EXAMPLE
    .\system_info.ps1 -OutputDir "C:\Logs"
    Saves the report to C:\Logs instead.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputDir = (Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "SysAdminReports")
)

# Set strict mode for better error catching
Set-StrictMode -Version Latest

# Generate timestamp for unique filename
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = Join-Path -Path $OutputDir -ChildPath "system_info_$timestamp.txt"

# Ensure output directory exists
try {
    if (-not (Test-Path -Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
} catch {
    Write-Error "Failed to create output directory '$OutputDir': $_"
    exit 1
}

# Collect system information
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
    $memorySize = $os.TotalVisibleMemorySize / 1MB  # Convert KB to GB
} catch {
    Write-Error "Failed to collect system information: $_"
    exit 1
}

# Write to file with error handling
try {
    "System Information Report" | Out-File -FilePath $outputFile -Encoding UTF8 -ErrorAction Stop
    "Generated: $(Get-Date)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "------------------------" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "OS Name: $($os.Caption)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "OS Version: $($os.Version)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "CPU: $($cpu.Name)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "Total Memory: $memorySize GB" | Out-File -FilePath $outputFile -Append -Encoding UTF8

    Write-Host "System information saved to: $outputFile" -ForegroundColor Green
} catch {
    Write-Error "Failed to write to '$outputFile': $_"
    exit 1
}