function Get-ADMemberOf
{
    <#
    .SYNOPSIS 
        Get Members of for a Computer or User.
    
    .DESCRIPTION 
        Get Members of for a Computer or User.
    
    .PARAMETER ComputerName
        Specifies a computer name.

    .PARAMETER Filter
        Specifies a custom filter.
    
    .PARAMETER Username
        Specifies an username.
    
    .EXAMPLE 
       PS C:\> Get-ADMemberOf -Username foo
       This command gets the groups for user foo.
    
    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   31/08/2018
        Modified:  24/09/2020
        Version:   1.3.4
    #> 

    [CmdletBinding(DefaultParameterSetName = 'Username')]
    param (
        [Parameter(ParameterSetName = 'Username')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Filter,
      
        [Parameter(ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
    )

    begin
    {
        $memberOf = @()
    }

    process
    {
        switch ($psCmdlet.ParameterSetName)
        {
            'Username'
            {
                (Get-ADUser -Identity $Username -Properties memberOf).MemberOf | 
                    Where-Object { $_ -like "*$Filter*" } | 
                        ForEach-Object {
                            $group = [ordered]@{
                                'GroupName' = ($_ -split ',*..=')[1]
                                'GroupOU'   = $_.Substring($_.IndexOf('OU='))
                            }
 
                            $memberOf += New-Object -TypeName PSCustomObject -Property $Group
                        }
            }

            'ComputerName'
            {
                (Get-ADComputer -Identity $ComputerName -Properties memberOf).MemberOf | 
                    Where-Object { $_ -like "*$Filter*" } | 
                        ForEach-Object {
                            $group = [ordered]@{
                                'GroupName' = ($_ -split ',*..=')[1]
                                'GroupOU'   = $_.Substring($_.IndexOf('OU='))
                            }
 
                            $memberOf += New-Object -TypeName PSCustomObject -Property $Group
                        }
            }
        }
    }
    
    end
    {
        $memberOf | Sort-Object 'Group Name' | Format-Table
    }
}