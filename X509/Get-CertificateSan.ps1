function Get-CertificateSan
{
    <#
    .SYNOPSIS
        Retrieves the Subject Alternative Name (SAN) of a certificate based on its serial number.

    .DESCRIPTION
        This function retrieves the Subject Alternative Name (SAN) of a certificate based on its serial number.

    .PARAMETER SerialNumber
        Specifies the serial number of the certificate.

    .PARAMETER ComputerName
        Specifies the name of the remote computer to retrieve certificates from. Defaults to the local computer.
    
    .PARAMETER Credential
        Specifies a user account with permissions to retrieve certificates from a remote computer.

    .EXAMPLE
        Get-CertificateSan -SerialNumber '1234567890' -ComputerName 'RemoteComputer' -Credential (Get-Credential)
        Retrieves the Subject Alternative Name (SAN) of the certificate with serial number '1234567890'.

    .NOTES
        Author:     Daniel Schwitzgebel
        Created:    02/05/2023
        Modified:   02/05/2023
        Version:    1.0
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SerialNumber,

        [Parameter()]
        [string]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $newPSSessionParam = @{
        ComputerName = $ComputerName
        ErrorAction  = 'Stop'
    }
		
    if ($Credential -ne [System.Management.Automation.PSCredential]::Empty)
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
        param($SerialNumber)
        $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('My', [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
        $certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $cert = $certStore.Certificates | Where-Object { $_.SerialNumber -eq $SerialNumber }
        $extension = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -eq 'Subject Alternative Name' }
        $extension.Format($false)
        $certStore.Close()
    }

    $invokeCommandParam = @{
        Session      = $session
        ScriptBlock  = $scriptBlock
        ArgumentList = $SerialNumber
    }

    Invoke-Command @invokeCommandParam
    Remove-PSSession -Session $session
}