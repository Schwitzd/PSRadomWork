param
(
    $data = 'empty',
    $address = 'Loopback',
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

$bytes = [Text.Encoding]::ASCII.GetBytes( $data )
$bytesSent = $udpclient.Send($bytes, $bytes.length, $endpoint)

$udpclient.Close()