# SET UP SESSION
# Get credentials
$UserCredential = Get-Credential

# Import the Active Directory module
Import-Module ActiveDirectory

# Start Exchange Session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ORG-URI/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking > $null

# Set the path to your CSV file
$csvFilePath = Read-Host "Please enter the path of the CSV file:"

# Read the CSV file
$csvData = Import-Csv $csvFilePath

##################################################################

# DECLARE VARIABLES
# Declare Company
$comp = "COMPANY NAME"

# Declare Offices
$Locations = @(
    @{ Office='Office 1'; Street='Street 1'; City='City 1'; Zip='ZIP 1' },
    @{ Office='Office 2'; Street='Street 2'; City='City 2'; Zip='ZIP 2' },
    @{ Office='Office 3'; Street='Street 3'; City='City 3'; Zip='ZIP 3' },
    @{ Office='Office 4'; Street='Street 4'; City='City 4'; Zip='ZIP 4' },
    @{ Office='Office 5'; Street='Street 5'; City='City 5'; Zip='ZIP 5' },
    @{ Office='Office 6'; Street='Street 6'; City='City 6'; Zip='ZIP 6' }
)

##################################################################

# MAIN LOOP
# Iterate through each row in the CSV file
foreach ($row in $csvData) {
  if ($row.'FirstName' -ne "") {  
    # Check user exists
    $exists = Get-ADUser -Filter "UserPrincipalName -eq '$($row.'UPN logon')'"
    if ($exists) {
        Write-Host "$($row.'UPN logon') already exists - please update CSV with new email address." -ForegroundColor Red }
    elseif ($($row.'UPN logon') -match '\s') {
        Write-Host "Skipping entry for UPN '$($row.'UPN logon')' because it contains a space." }
    else {
        # Generate on-prem mailbox
        $SecurePassword = ConvertTo-SecureString "password" -AsPlainText -Force
        $fullname = $($row.'FirstName') + " " + $($row.'LastName')
        New-RemoteMailbox -Name $fullname -Password $SecurePassword -UserPrincipalName $($row.'UPN logon') -FirstName $($row.'FirstName') -LastName $($row.'LastName') -OnPremisesOrganizationalUnit "ORG UNIT" -Archive -SamAccountName $($row.'SamAccountName logon') > $null
    
        # Allow sync time
        Start-Sleep -Seconds 5

        # Retrieve the user
        $user = Get-ADUser -Filter "UserPrincipalName -eq '$($row.'UPN logon')'"

        # Check if the user is found
        if ($user) {
            # Update user properties
            Set-ADUser -Identity $user.DistinguishedName -Office $row.Office -Title $row.'Job title' -Department $row.Department -Company $comp -Description $row.'Job title'
        
            #Update Offices
            $SelectedLocation = $Locations | Where-Object { $_.Office -eq $row.Office }
            if ($SelectedLocation) {
                Set-ADUser -Identity $user.DistinguishedName -StreetAddress $SelectedLocation.Street -City $SelectedLocation.City -PostalCode $SelectedLocation.Zip
            }
        
            # Set Manager if provided
            if ($row.Manager) {
                $manager = Get-ADUser -Filter "UserPrincipalName -eq '$($row.Manager)'"
                if ($manager) {
                    Set-ADUser -Identity $user.DistinguishedName -Manager $manager.DistinguishedName
                } else {
                    Write-Host "Manager with UPN $($row.Manager) not found." -ForegroundColor Red
                }
            }

            # Set Account Expiry Date if provided
            if ($row.AccountExpDate -ne "") {
                try {
                    # Parsing the date assuming day/month/year format
                    $expiryDate = [DateTime]::ParseExact($row.AccountExpDate, "dd/MM/yyyy", $null)
                
                    # Add one day and subtract one second to set it to 23:59:59 on that day
                    $expiryDate = $expiryDate.AddDays(1).AddSeconds(-1)
                
                    Set-ADUser -Identity $user.DistinguishedName -AccountExpirationDate $expiryDate
                    Write-Host "Account expiry date for $($user.UserPrincipalName) set to $($expiryDate.ToString())"
                } catch {
                    Write-Host "Failed to set account expiry date for $($user.SamAccountName). Invalid date format: $($row.AccountExpDate)" -ForegroundColor Red
                }
                }
        
            # Apply Standard Groups
            $uname = $row.'SamAccountName logon'
            Get-ADUser -Identity StandardTemplate -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $uname

            # Set the logon script text
            $logonScriptText = "LOGON SCRIPT"
            # Set the attribute name for the logon script in Active Directory
            $logonScriptAttribute = "scriptPath"
            # Update the user's logon script attribute
            Set-ADUser -Identity $user.DistinguishedName -Replace @{ $logonScriptAttribute = $logonScriptText }

            # Close
            Write-Host "User $($user.UserPrincipalName) updated successfully." -ForegroundColor Green

            }
        else {
            Write-Host "Username $($row.'UPN logon') not found." -ForegroundColor Red }
       }
    }
  }

##################################################################

# Close session
Remove-PSSession $Session
Read-Host "Please review, and then press enter"


