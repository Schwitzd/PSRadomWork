function Get-ADMemberOf
{
    <#
    .SYNOPSIS 
        Get Members of for a Computer or User.
    
    .DESCRIPTION 
        Get Members of for a Computer or User.
    
    .PARAMETER ComputerName
        A single Computer name.
    
    .PARAMETER Username
        Name of the person.
    
    .EXAMPLE 
       PS C:\> Get-ADMemberOf -Username foo
    
    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   31/08/2018
        Modified:  22/05/2019
        Version:   1.3.2
        Changes:   1.1    Change - Removed Positional parameter
                   1.2    Change - Code Refactoring
                   1.3    Add    - Added Username as DefaultParameterSetName
                          Add    - Enforced Parameter validation
                   1.3.1  Change - fixed a typo issue with ValidateNotNullOrEmpty
                   1.3.2  Change - Code style improvement
    #> 

    [CmdletBinding(DefaultParameterSetName = 'Username')]
    param(
        [Parameter(ParameterSetName = 'Username')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,
      
        [Parameter(ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Filter
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
                                'Group Name' = ($_ -split ',*..=')[1]
                                'Group OU'   = $_.Substring($_.IndexOf('OU='))
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
                                'Group Name' = ($_ -split ',*..=')[1]
                                'Group OU'   = $_.Substring($_.IndexOf('OU='))
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