function Get-DNSHostnameAliases
{
    <# 
    .SYNOPSIS 
        Get all DNS Aliases for a given computer name.
    
    .DESCRIPTION 
        Get all DNS Aliases for a given computer name by querying the specified DNS Zone.
    
    .PARAMETER ComputerName
        Specified the computer name to lookup.

    .PARAMETER DNSServer
        Specified the DNS Server name. 
    
    .PARAMETER DNSZone
        Specified the name of the DNS Zone.
      
    .EXAMPLE 
        PS C:\> Get-DNSHostnameAliases -DNSServer foo -DNSZone foo_zone -ComputerName bar
        This command get aa the DNS Aliases for a given computer name.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    23/03/2020
        Modified:   09/04/2020
        Version:    1.0.1

  #> 

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DNSServer,
      
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DNSZone
    )

    process
    {
        try
        {
            Get-DnsServerResourceRecord -ZoneName $DNSZone -ComputerName $DNSServer | 
                Where-Object { $_.RecordData.HostNameAlias -like "$ComputerName*" } | 
                    Select-Object Hostname -ExpandProperty RecordData
        }
        catch
        {
            throw 'failed to query the DNS Server or RSAT DNS Server not installed'
        }
    }
}