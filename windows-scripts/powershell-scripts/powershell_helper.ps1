<#
.SYNOPSIS
    An interactive PowerShell command helper that simplifies accessing help information.
    
.DESCRIPTION
    This script provides a user-friendly way to access PowerShell command help information.
    It allows users to search for commands, view different help formats, and save output.
    
.EXAMPLE
    .\PowerShellHelper.ps1
    Launches the interactive PowerShell helper menu.
    
.NOTES
    Author: Claude
    Date: April 1, 2025
#>

function Show-CommandHelper {
    [CmdletBinding()]
    param()
    
    Clear-Host
    Write-Host "===== PowerShell Command Helper =====" -ForegroundColor Cyan
    
    # Main interaction loop
    while ($true) {
        Write-Host "`nWhat would you like to do?" -ForegroundColor Yellow
        Write-Host "1: Search for a command"
        Write-Host "2: Get help for a specific command"
        Write-Host "3: Browse common commands by category"
        Write-Host "4: Save command help to a file"
        Write-Host "5: Exit"
        
        $choice = Read-Host "`nEnter your choice (1-5)"
        
        switch ($choice) {
            "1" { Search-Command }
            "2" { Get-CommandHelp }
            "3" { Browse-CommandCategories }
            "4" { Save-CommandHelp }
            "5" { 
                Write-Host "`nExiting PowerShell Helper. Goodbye!" -ForegroundColor Green
                return 
            }
            default { Write-Host "`nInvalid choice. Please enter a number between 1 and 5." -ForegroundColor Red }
        }
    }
}

function Search-Command {
    $searchTerm = Read-Host "`nEnter search term for commands"
    
    if ([string]::IsNullOrWhiteSpace($searchTerm)) {
        Write-Host "Search term cannot be empty." -ForegroundColor Red
        return
    }
    
    Write-Host "`nSearching for commands matching '$searchTerm'..." -ForegroundColor Yellow
    
    $results = Get-Command -Name "*$searchTerm*" | Select-Object Name, CommandType, ModuleName | Sort-Object Name
    
    if ($results.Count -eq 0) {
        Write-Host "No commands found matching '$searchTerm'." -ForegroundColor Red
    }
    else {
        Write-Host "`nFound $($results.Count) matching commands:" -ForegroundColor Green
        $results | Format-Table -AutoSize
        
        $commandChoice = Read-Host "Enter the exact name of a command to see its help (or press Enter to return)"
        
        if (-not [string]::IsNullOrWhiteSpace($commandChoice)) {
            try {
                Show-HelpOptions $commandChoice
            }
            catch {
                Write-Host "Error displaying help for '$commandChoice': $_" -ForegroundColor Red
            }
        }
    }
}

function Get-CommandHelp {
    $commandName = Read-Host "`nEnter the exact name of the command"
    
    if ([string]::IsNullOrWhiteSpace($commandName)) {
        Write-Host "Command name cannot be empty." -ForegroundColor Red
        return
    }
    
    try {
        Show-HelpOptions $commandName
    }
    catch {
        Write-Host "Error displaying help for '$commandName': $_" -ForegroundColor Red
    }
}

function Show-HelpOptions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )
    
    # Verify the command exists
    try {
        $null = Get-Command $CommandName -ErrorAction Stop
    }
    catch {
        Write-Host "Command '$CommandName' not found. Please check the spelling and try again." -ForegroundColor Red
        return
    }
    
    # Show help options
    $validChoice = $false
    
    while (-not $validChoice) {
        Write-Host "`nHow would you like to view help for '$CommandName'?" -ForegroundColor Yellow
        Write-Host "1: Basic help"
        Write-Host "2: Detailed help"
        Write-Host "3: Full help"
        Write-Host "4: Examples only"
        Write-Host "5: Online help (if available)"
        Write-Host "6: Parameter help"
        Write-Host "7: Return to main menu"
        
        $helpChoice = Read-Host "`nEnter your choice (1-7)"
        
        switch ($helpChoice) {
            "1" { 
                Get-Help $CommandName
                $validChoice = $true 
            }
            "2" { 
                Get-Help $CommandName -Detailed
                $validChoice = $true 
            }
            "3" { 
                Get-Help $CommandName -Full
                $validChoice = $true 
            }
            "4" { 
                Get-Help $CommandName -Examples
                $validChoice = $true 
            }
            "5" { 
                try {
                    Get-Help $CommandName -Online -ErrorAction Stop
                    Write-Host "Opening online help in your web browser..." -ForegroundColor Green
                }
                catch {
                    Write-Host "Online help is not available for this command." -ForegroundColor Red
                }
                $validChoice = $true 
            }
            "6" { 
                $paramName = Read-Host "Enter parameter name (without the dash)"
                if (-not [string]::IsNullOrWhiteSpace($paramName)) {
                    Get-Help $CommandName -Parameter $paramName
                }
                $validChoice = $true 
            }
            "7" { 
                $validChoice = $true 
                return
            }
            default { Write-Host "`nInvalid choice. Please enter a number between 1 and 7." -ForegroundColor Red }
        }
    }
    
    Write-Host "`nPress Enter to continue..." -ForegroundColor Cyan
    $null = Read-Host
}

function Browse-CommandCategories {
    $categories = @{
        "1" = @{Name = "File System"; Commands = @("Get-ChildItem", "Get-Content", "Set-Content", "Copy-Item", "Move-Item", "Remove-Item") }
        "2" = @{Name = "Processes & Services"; Commands = @("Get-Process", "Stop-Process", "Get-Service", "Start-Service", "Stop-Service") }
        "3" = @{Name = "Network"; Commands = @("Test-Connection", "Get-NetAdapter", "Get-NetIPAddress", "Resolve-DnsName") }
        "4" = @{Name = "System Information"; Commands = @("Get-ComputerInfo", "Get-WmiObject", "Get-CimInstance", "Get-EventLog") }
        "5" = @{Name = "PowerShell Management"; Commands = @("Get-Command", "Get-Help", "Get-Module", "Import-Module") }
    }
    
    Write-Host "`nSelect a command category:" -ForegroundColor Yellow
    foreach ($key in $categories.Keys | Sort-Object) {
        Write-Host "$key`: $($categories[$key].Name)"
    }
    Write-Host "6: Return to main menu"
    
    $categoryChoice = Read-Host "`nEnter your choice (1-6)"
    
    if ($categoryChoice -eq "6") {
        return
    }
    
    if ($categories.ContainsKey($categoryChoice)) {
        $category = $categories[$categoryChoice]
        Write-Host "`nCommon $($category.Name) commands:" -ForegroundColor Green
        
        for ($i = 0; $i -lt $category.Commands.Count; $i++) {
            Write-Host "$($i+1): $($category.Commands[$i])"
        }
        
        $commandIndex = [int](Read-Host "`nEnter command number to view its help (or 0 to return)")
        
        if ($commandIndex -gt 0 -and $commandIndex -le $category.Commands.Count) {
            $selectedCommand = $category.Commands[$commandIndex-1]
            Show-HelpOptions $selectedCommand
        }
    }
    else {
        Write-Host "Invalid category choice." -ForegroundColor Red
    }
}

function Save-CommandHelp {
    $commandName = Read-Host "`nEnter the exact name of the command"
    
    if ([string]::IsNullOrWhiteSpace($commandName)) {
        Write-Host "Command name cannot be empty." -ForegroundColor Red
        return
    }
    
    # Verify the command exists
    try {
        $null = Get-Command $commandName -ErrorAction Stop
    }
    catch {
        Write-Host "Command '$commandName' not found. Please check the spelling and try again." -ForegroundColor Red
        return
    }
    
    $filePath = Read-Host "Enter the file path to save help (default: .\$commandName-help.txt)"
    
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        $filePath = ".\$commandName-help.txt"
    }
    
    try {
        Get-Help $commandName -Full | Out-File -FilePath $filePath -Force
        Write-Host "Help information for '$commandName' has been saved to '$filePath'." -ForegroundColor Green
    }
    catch {
        Write-Host "Error saving help information: $_" -ForegroundColor Red
    }
}

# Start the command helper
Show-CommandHelper