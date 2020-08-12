param
(
    $address = 'Any', 
    $port = 2020
)

try
{
    $endpoint = New-Object System.Net.IPEndPoint([ipaddress]::$address, $port) 
    $listener = New-Object System.Net.Sockets.TcpListener $EndPoint
    $listener.start()
    $incomingClient = $listener.AcceptTcpClient()  
}
catch
{
    throw $_.Exception.Message
}

Write-Host 'Press ESC to stop the tcp server...' -fore yellow
Write-Host ''

while ($true)
{
    if ($host.ui.RawUi.KeyAvailable)
    {
        $key = $host.ui.RawUI.ReadKey('NoEcho,IncludeKeyUp,IncludeKeyDown')
        if ($key.VirtualKeyCode -eq 27)
        { break }
    }

    if ($Listener.Pending())
    { 
        Write-Output "$($incomingClient.Client.RemoteEndPoint.Address.IPAddressToString):$($IncomingClient.Client.RemoteEndPoint.Port))"
    }
}

$listener.stop()
$listener.server.Dispose()