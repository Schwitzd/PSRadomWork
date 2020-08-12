param
(
    $address = 'Any', 
    $port = 2020
)

try
{
    $endpoint = New-Object System.Net.IPEndPoint([IPAddress]::$address, $port)
    $udpclient = New-Object System.Net.Sockets.UdpClient $endpoint
}
catch
{
    throw $_.Exception.Message
}

Write-Host 'Press ESC to stop the udp server...' -fore yellow
Write-Host ''

while ($true)
{
    if ($host.ui.RawUi.KeyAvailable)
    {
        $key = $host.ui.RawUI.ReadKey('NoEcho,IncludeKeyUp,IncludeKeyDown')
        if ($key.VirtualKeyCode -eq 27)
        { break }
    }

    if ($udpclient.Available)
    {
        $content = $udpclient.Receive([ref]$endpoint)
        Write-Output "$($endpoint.Address.IPAddressToString):$($endpoint.Port) $([Text.Encoding]::ASCII.GetString($content))"
    }
}

$udpclient.Close( )