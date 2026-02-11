do {

    # Gather information
    $choice = Read-Host "Enable (e) or disable (d)?"
    $DeviceName = Read-Host "Enter the device name: "
    $TargetOU = Read-Host "Enter Distinguished Name of destination OU: "
    
    # Find the computer object
    $Computer = Get-ADComputer -Filter "Name -eq '$DeviceName'"

    # Enable
    if ($choice -eq "e") {
        if ($Computer) {
            # Enable object
            Enable-ADAccount -Identity $Computer
            # Move object
            Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $TargetOU
            # Notify user
            Write-Host "Device '$DeviceName' moved to '$TargetOU' and enabled successfully."
        }
        else {
            Write-Host "Computer '$DeviceName' not found in Active Directory."
        }
        }
    # Disable
    elseif ($choice -eq "d") {
        if ($Computer) {
            # Disable object
            Disable-ADAccount -Identity $Computer
            # Move object
            Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $TargetOU
            # Notify user
            Write-Host "Device '$DeviceName' moved to '$TargetOU' and disabled successfully."
        }
        else {
            Write-Host "Computer '$DeviceName' not found in Active Directory."
        }
        }

    # Loop condition
    $Continue = Read-Host "Do you want to update another device? (y/n)"

} while ($Continue -eq "y")
