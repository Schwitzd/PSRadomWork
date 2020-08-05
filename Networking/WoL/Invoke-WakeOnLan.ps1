function Invoke-WakeOnLan
{
    <#
    .SYNOPSIS 
        This function will wake up a computer.
  
    .DESCRIPTION 
        This function will wake up a computer by sending a magic packet.
  
    .PARAMETER MacAddress 
        Specifies the mac address.

    .PARAMETER BroadcastNetwork 
        Specifies the broadcast address.
    
    .EXAMPLE 
        PS C:\> Invoke-WakeOnLan -MacAddress '21:C1:9A:A6:AA:05'
        This command send magic packet to the specified MAC Address

    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   02/01/2017
        Modified:  05/08/2020
        Version:   1.2
    #>

    [OutputType([Void])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
        [String]
        $MacAddress,

        [Parameter(Mandatory)]
        [ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(255)$')]
        [String]
        $BroadcastNetwork
    )
 
    $udpClient = [System.Net.Sockets.UdpClient]::new()
    $wolPort = 9511

    foreach ($currentMacAddress in $MacAddress)
    {
        try
        {   
            # get byte array from mac address:
            $mac = $MacAddress -split '[:-]' |
                # convert the hex number into byte:
                ForEach-Object {
                    [System.Convert]::ToByte($_, 16)
                }
        
            # create a byte array with 102 bytes initialized to 255 each:
            $packet = [byte[]](, 0xFF * 102)
        
            # leave the first 6 bytes untouched, and
            # repeat the target mac address bytes in bytes 7 through 102:
            6..101 | ForEach-Object { 
                # $_ is indexing in the byte array,
                # $_ % 6 produces repeating indices between 0 and 5
                # (modulo operator)
                $packet[$_] = $mac[($_ % 6)]
            }

            $udpClient.Connect($BroadcastNetwork, $wolPort)
        
            $null = $udpClient.Send($packet, $packet.Length)
            Write-Verbose "sent magic packet to $MacAddress on broadcast $BroadcastNetwork"
        }
        catch 
        {
            Write-Warning "Unable to send magic packet for $MacAddress"
        }
    }
    
    $udpClient.Close()
    $udpClient.Dispose()
}