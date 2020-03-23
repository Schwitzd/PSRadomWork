function Get-DNSHostnameAliases
{
    <# 
    .SYNOPSIS 
        Get all DNS Aliases for a given Hostname.
    
    .DESCRIPTION 
        Get all DNS Aliases for a given Hostname by querying the specified DNS Zone.
    
    .PARAMETER DNSServer
        Name of the DNS Server to query. 
    
    .PARAMETER DNSZone
        Name of the DNS Zone.

    .PARAMETER Hostname
        Name of the Hostname to lookup.
      
    .EXAMPLE 
        PS C:\> Get-DNSHostnameAliases -DNSServer foo -DNSZone foo_zone -Hostname bar
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    23/03/2020
        Modified:   23/03/2020
        Version:    1.0

  #> 

    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty]
        [String]
        $DNSServer,
      
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty]
        [String]
        $DNSZone,
      
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty]
        [String]
        $Hostname
    )

    begin
    {
    }
 
    process
    {
        try
        {
            Get-DnsServerResourceRecord -ZoneName $DNSZone -ComputerName $DNSServer | 
                Where-Object { $_.RecordData.HostNameAlias -like "$Hostname*" } | 
                    Select-Object Hostname -ExpandProperty RecordData
        }

        catch
        {
            throw 'failed to query the DNS Server or RSAT DNS Server not installed'
        }
    }
}