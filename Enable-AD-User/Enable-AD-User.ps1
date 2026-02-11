do {
  # Gather details
  $SamAccountName = Read-Host "Enter the SamAccountName"
  $DestinationOU = Read-Host "Enter Distinguished Name of destination OU: "
  $usertemplate = Read-Host "Enter target username for group template: "
  
  #Find user
  $user = Get-ADUser -Identity $SamAccountName
  
  # Enable user
  Enable-ADAccount -Identity $SamAccountName
  
  # Move user to destination OU
  Move-ADObject -Identity $user.DistinguishedName -TargetPath $DestinationOU
  
  # Restore job title
  $user = Get-ADUser -Identity $SamAccountName -Properties Title
  $jobTitle = $user.Title
  Set-ADUser -Identity $SamAccountName -Description $jobTitle
  
  # Add template groups
  Get-ADUser -Identity $usertemplate -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $SamAccountName 
  
  # Unhide mailbox
  Set-ADUser $user.DistinguishedName -Replace @{msExchHideFromAddressLists=$false}
  
  $Continue = Read-Host "Account '$SamAccountName' has been enabled. Do you want to update another profile? (y/n)"

} while ($Continue -eq "y")
