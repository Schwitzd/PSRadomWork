Function Get-CmdletRiskLevel 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $CmdletName
    ) 

    $cmdlet = Get-Command -Name $CmdletName -CommandType Cmdlet
    $cmdletType = $cmdlet.ImplementingType

    $attribute = $cmdletType.GetCustomAttributes([System.Management.Automation.CmdletAttribute], $true)

    $attribute | Select-Object -Property *

}