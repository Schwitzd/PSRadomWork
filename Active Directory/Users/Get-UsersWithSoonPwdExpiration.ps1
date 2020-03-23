$maxPswAgeTime = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
$ou = '' 

Get-ADUser -SearchBase $ou -Properties PasswordLastSet -Filter * | 
    Where-Object { ($_.PasswordLastSet + $maxPswAgeTime) -gt (Get-Date) } | 
        Select-Object @{
            label = 'Name'; expression = { "$($_.givenName) $($_.Surname)" } 
        }, 
        @{ 
            label = 'Password Expiration Date'; expression = { ($_.PasswordLastSet + $maxPswAgeTime) } 
        } | 
            Sort-Object 'Password Expiration Date'