<#
.SYNOPSIS
  Retrieves a list of installed programs from HKLM (system-wide) and HKU (per user).

.DESCRIPTION
  This script queries the registry for both 64-bit and 32-bit installed software 
  under HKEY_LOCAL_MACHINE, and then enumerates each user's SID under HKEY_USERS 
  to find user-specific programs. It attempts to resolve each SID to a friendly 
  account name.

.NOTES
  You may need to adjust your execution policy to run local scripts:
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

# Paths under HKLM to check (64-bit and 32-bit on 64-bit OS)
$hklmPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

Write-Host "`n===== System-Wide Installed Programs (HKLM) =====`n"

foreach ($path in $hklmPaths) {
    if (Test-Path $path) {
        Get-ChildItem $path | ForEach-Object {
            $regKey = $_.PSPath
            $props = Get-ItemProperty $regKey -ErrorAction SilentlyContinue

            if ($props.DisplayName) {
                [PSCustomObject]@{
                    Name        = $props.DisplayName
                    Version     = $props.DisplayVersion
                    Publisher   = $props.Publisher
                    InstallDate = $props.InstallDate
                    InstalledBy = "System-Wide (HKLM)"
                }
            }
        }
    }
}

Write-Host "`n===== User-Specific Installed Programs (HKU) =====`n"

# Enumerate each SID in HKEY_USERS that looks like a standard user SID (S-1-5-21-...)
Get-ChildItem "HKU:\" | Where-Object { $_.PSChildName -match "^S-1-5-21" } | ForEach-Object {
    $sid = $_.PSChildName

    # Attempt to convert SID to a username
    try {
        $userName = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount])
    } catch {
        $userName = "Unknown or unable to resolve"
    }

    # Construct the "Uninstall" path for this user's SID
    $userRegPath = "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    if (Test-Path $userRegPath) {
        Get-ChildItem $userRegPath | ForEach-Object {
            $userProps = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            if ($userProps.DisplayName) {
                [PSCustomObject]@{
                    Name        = $userProps.DisplayName
                    Version     = $userProps.DisplayVersion
                    Publisher   = $userProps.Publisher
                    InstallDate = $userProps.InstallDate
                    InstalledBy = $userName
                }
            }
        }
    }
}
