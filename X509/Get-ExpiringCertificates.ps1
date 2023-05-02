function Get-ExpiringCertificates
{
    <#
    .SYNOPSIS
    Retrieves certificates from the LocalMachine\My store on a remote or local computer that will expire within a specified number of days.

    .DESCRIPTION
    This function retrieves certificates from the LocalMachine\My store on a remote or local computer that will expire within a specified number of days.

    .PARAMETER ExpirationDays
    Specifies the number of days before a certificate expires.

    .PARAMETER ComputerName
    Specifies the name of the remote computer to retrieve certificates from. Defaults to the local computer.

    .PARAMETER Credential
    Specifies a user account with permissions to retrieve certificates from a remote computer.

    .EXAMPLE
    PS C:\> Get-ExpiringCertificates -ExpirationDays 60 -ComputerName MyServer -Credential MyDomain\Administrator
    Returns all certificates that will expire within the next 60 days on the MyServer computer using the MyDomain\Administrator account.

    .NOTES
        Author:     Daniel Schwitzgebel
        Created:    02/05/2023
        Modified:   02/05/2023
        Version:    1.0
    #>

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(1, 365)]
        [int]
        $ExpirationDays,

        [Parameter()]
        [string]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
	
    $newPSSessionParam = @{
        ComputerName = $ComputerName
        ErrorAction  = 'Stop'
    }
		
    if ($credential)
    {
        $newPSSessionParam['Credential'] = $Credential
    }		

    try
    {
        $session = New-PSSession @newPSSessionParam
    }
    catch
    {
        Throw $_.Exception.Message
    }
    
    $scriptBlock = {
        param($ExpirationDays)
        $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
        $certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $certificates = $certStore.Certificates | Where-Object { $_.NotAfter -lt (Get-Date).AddDays($ExpirationDays) }
        $certificates | ForEach-Object {
            [PSCustomObject]@{
                Subject    = $_.Subject
                Issuer     = $_.Issuer
                Thumbprint = $_.Thumbprint
                NotAfter   = $_.NotAfter
            }
        }
        $certStore.Close()
    }

    $invokeCommandParam = @{
        Session = $session
        ScriptBlock = $scriptBlock
        ArgumentList = $ExpirationDays
    }

    Invoke-Command @invokeCommandParam
    Remove-PSSession -Session $session
}