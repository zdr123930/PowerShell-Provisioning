# Function to bulk update user password in Active Directory
function Update-UserPassword {
    param (
        [string]$username,
        [string]$newPassword
    )
    
    # Get the user object from Active Directory
    $user = Get-ADUser -Filter "SamAccountName -eq '$username'" -Properties DistinguishedName
    
    if ($user) {
        try {
            # Set the new password for the user
            $userDN = $user.DistinguishedName
            Set-ADAccountPassword -Identity $userDN -NewPassword (ConvertTo-SecureString -String $newPassword -AsPlainText -Force)
            
            # Set flag to prompt user to change password at next logon
            Set-ADUser -Identity $userDN -ChangePasswordAtLogon $true
            
            Write-Host "Password updated successfully for user: $username"
        }
        catch {
            Write-Host "Failed to update password for user: $username. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "User not found: $username" -ForegroundColor Yellow
    }
}

# Prompt for a list of usernames separated by commas
$usernames = Read-Host "Enter a list of usernames separated by commas"

# Convert the comma-separated list of usernames into an array
$usernamesArray = $usernames -split ','

# Prompt for the new password
$newPassword = Read-Host "Enter the new password: "

# Loop through each username and update their password
foreach ($username in $usernamesArray) {
    Update-UserPassword -username $username.Trim() -newPassword $newPassword
}
