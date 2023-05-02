function Get-ComputerSpn
{
    <#
    .SYNOPSIS
    Retrieves the Service Principal Names (SPNs) associated with a given computer name.
    
    .DESCRIPTION
    This function retrieves the SPNs registered in Active Directory for a specified computer name.
    
    .PARAMETER ComputerName
    The name of the computer for which to retrieve the SPNs.
    
    .EXAMPLE
    Get-ComputerSPN -ComputerName "Computer01"
    Retrieves the SPNs associated with the computer named "Computer01".
    
    .NOTES
    This function requires the Active Directory module to be installed and loaded in the PowerShell session.

    Author:     Daniel Schwitzgebel
    Created:    18/04/2023
    Modified:   18/04/2023
    Version:    1.0
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName
    )

    begin
    {
        if (-not (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue))
        {
            Import-Module ActiveDirectory
        }
    }
    process
    {
        try
        {
            $getADComputerParam = @{
                Identity    = $ComputerName
                Properties  = 'ServicePrincipalNames'
                ErrorAction = 'Stop'
            }

            $computer = Get-ADComputer @getADComputerParam
            $spsn = ($computer.ServicePrincipalNames).split('\s')
            Write-Output $spsn
            
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
}