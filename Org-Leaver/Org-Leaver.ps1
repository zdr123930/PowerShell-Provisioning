do {

    # Collect details
    $samAccountName = Read-Host "Enter target username: "
    $targetOU = Read-Host "Please enter Distinguished Name of target OU: "
    
    # Find user
    $user = Get-ADUser -Identity $SamAccountName

    # Specify the groups to remove the user from
    $groupsToRemove = @(
        "Group1",
        "Group2"
    )
    
    # Remove user from specified groups
    foreach ($group in $groupsToRemove) {
        Remove-ADGroupMember -Identity $group -Members $user.DistinguishedName -Confirm:$false
    }

    # Disable the account
    Disable-ADAccount -Identity $user.DistinguishedName

    # Hide mailbox
    Set-ADUser $user.DistinguishedName -Replace @{msExchHideFromAddressLists=$true}

    # Move the user to the specified OU
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU

    # Loop condition
    $Continue = Read-Host "Leavers process complete. Do you want to update another profile? (y/n)"

} while ($Continue -eq "y")
