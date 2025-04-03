<#
.SYNOPSIS
    Retrieves and displays information about all Active Directory users.

.DESCRIPTION
    This script uses the Active Directory PowerShell module to fetch user
    information such as SamAccountName, DisplayName, EmailAddress, Department, Title, 
    and City for all users in the AD domain.

.NOTES
    You can customize which properties you want to retrieve by adding or removing them
    from the Properties parameter and the Select-Object line.
#>

# Import the Active Directory module (uncomment if needed)
# Import-Module ActiveDirectory

# Retrieve all users from Active Directory
$users = Get-ADUser -Filter * -Properties DisplayName, EmailAddress, Department, Title, City

# Select the properties you want to display
$selectedUserInfo = $users | Select-Object SamAccountName,
                                      DisplayName,
                                      EmailAddress,
                                      Department,
                                      Title,
                                      City

# Print the results to the screen
$selectedUserInfo

# Optionally, you can export this information to a CSV file:
# $selectedUserInfo | Export-Csv -Path "C:\Temp\AllUsersInfo.csv" -NoTypeInformation
