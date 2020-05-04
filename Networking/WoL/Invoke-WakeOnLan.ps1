function Invoke-WakeOnLan
{
    <#
    .SYNOPSIS 
        This function will wake up a computer.
  
    .DESCRIPTION 
        This function will wake up a computer by sending a magic packet.
  
    .PARAMETER Path 
        Specifies the mac address.
    
    .EXAMPLE 
        PS C:\> Invoke-WakeOnLan -MacAddress '21:C1:9A:A6:AA:05', '33:E8:AB:B5:42:0F'
        This command import the specified scheduled task.
  
    .NOTES
        Thanks to Powershell.one

    .LINK
    http://powershell.one/code/11.html
    #>

    [OutputType([Void])]
    [CmdletBinging()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
        [String[]]
        $MacAddress
    )
 
    begin
    {
        $udpClient = [System.Net.Sockets.UdpClient]::new()
    }

    process
    {
        foreach ($currentMacAddress in $MacAddress)
        {
            try
            {        
                # get byte array from mac address:
                $mac = $currentMacAddress -split '[:-]' |
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

                $udpClient.Connect(([System.Net.IPAddress]::Broadcast), 4000)
        
                $null = $udpClient.Send($packet, $packet.Length)
                Write-Verbose "sent magic packet to $currentMacAddress..."
            }
            catch 
            {
                Write-Warning "Unable to send ${mac}: $currentMacAddress"
            }
        }
    }

    end
    {
        $udpClient.Close()
        $udpClient.Dispose()
    }
}