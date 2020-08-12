param
(
    $data = 'empty',
    $server = 'Loopback',
    $port = 2020
)

try
{
    $sourcePort = Get-Random -Minimum 48086 -Maximum 53042
    $endpoint = New-Object System.Net.IPEndPoint([IPAddress]::any, $sourcePort)
    $tcpclient = New-Object System.Net.Sockets.tcpclient $endpoint 
    $tcpclient.Connect($server, $port)
}
catch
{
    throw $_.Exception.Message
}

$tcpclient.Close()