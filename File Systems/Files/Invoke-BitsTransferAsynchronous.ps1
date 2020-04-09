function Invoke-BitsTransferAsynchronous
{

    <#
    .SYNOPSIS 
        This cmdlet create a BITS transfer job to transfer a file between a client and a server.

    .DESCRIPTION
        This cmdlet create a BITS transfer job in asynchronous mode to transfer a file between a client and a server.

    .PARAMETER Destination
        Specifies the destination location.

    .PARAMETER Priority 
        Sets the priority of the BITS transfer job, which affects bandwidth usage. The acceptable values for this parameter are:

        -- High: Background transfers use the idle network bandwidth of the client computer to transfer files.

        -- Normal (default): Background transfers use the idle network bandwidth of the client computer to transfer files.

        -- Low: Background transfers use the idle network bandwidth of the client to transfer files. 
                This is the lowest background priority level.

    .PARAMETER Proxy
        Specifies the Proxy server with port to use.

    .PARAMETER Source
        Specifies the source location and the name of the file that you want to transfer.

    .PARAMETER TransferType
        Specifies the BITS transfer job type. The acceptable values for this parameter are:

        -- Download (default): Specifies that the transfer job downloads files to the client computer.

        -- Upload: Specifies that the transfer job uploads a file to the server.

    .EXAMPLE 
        PS C:\> Invoke-BitsTransferAsynchronous -Source 'https://www.foo.com/bar.iso' -Destination '\\foo\c$\temp' -Priority 'Low' -Proxy 'myproxy:8080'
        This command download a file from Internet using proxy in Priority mode low.

        PS C:\> Invoke-BitsTransferAsynchronous -Source 'c:\temp\foo.iso' -Destination '\\foo\c$\temp'
        This command transfer a file to a server.

    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    09/04/2020
        Modified:   09/04/2020
        Version:    1.0
    #>

    [OutputType([Void])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $Source,

        [Parameter(Mandatory)]
        [String]
        $Destination,

        [Parameter()]
        [ValidateSet('High', 'Normal', 'Low')]
        [String]
        $Priority = 'Normal',

        [Parameter()]
        [ValidateSet('Download' , 'Upload')]
        $TransferType = 'Download',

        [Parameter()]
        [String]
        $Proxy
    )

    process
    {
        if ($Destination -match '(http[s]?)(:\/\/)([^\s,]+)')
        {
            $TransferType = 'Upload'
        }

        if ($Proxy)
        {
            $invokeBitsTransferAsynchronousParam = @{
                Source       = $Source
                Destination  = $Destination
                Priority     = $Priority
                TransferType = $TransferType
                Asynchronous = $true
                ProxyUsage   = 'Override'
                ProxyList    = $Proxy
            }
        }
        else
        {
            $invokeBitsTransferAsynchronousParam = @{
                Source       = $Source
                Destination  = $Destination
                Priority     = $Priority
                TransferType = $TransferType
                Asynchronous = $true
            }
        }

        try 
        {
            $bitsJob = Start-BitsTransfer @invokeBitsTransferAsynchronousParam

            do 
            {
                Start-Sleep -Seconds 2
                if ($bitsJob.JobState -eq 'TransientError')
                {
                    throw 'Failed to perform the operation, Job State is TransientError.'
                }
            } until ($bitsJob.JobState -eq 'Transferred')

            $bitsJob | Complete-BitsTransfer
        }
        catch 
        {
            $bitsJob | Remove-BitsTransfer
            throw $_.Exception.Message
        }
    }
}