function Get-KerberosTicketDomainGroup
{
    <#
  .SYNOPSIS 
    This function will get the domain groups inside the Kerberos Ticket.
  
  .DESCRIPTION 
    This function will use the utility whoami to get the domain groups inside the Kerberos Ticket.
  
  .EXAMPLE 
    PS C:\> Get-KerberosTicketDomainGroup
    This command gets the list of domain group stored in the Kerberos Ticket.
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   12/08/2020
    Modified:  12/08/2020
    Version:   1.0
  #>

    [OutputType([string])]
    param ()

    $kGroups = whoami /groups /fo CSV | ConvertFrom-Csv
    $kGroups | Where-Object { $_."Group Name" -like "$env:USERDOMAIN\*" } |
        Select-Object "Group Name", SID
}