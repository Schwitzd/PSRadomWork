function Stop-RemoteProcess
{
    <#
    .SYNOPSIS 
        Kill a process on a remote Computer.
    
    .DESCRIPTION 
        Get the list of processes running on a remote computer and kill the selected.
    
    .PARAMETER ComputerName
        A single Computer.
    
    .EXAMPLE 
        PS C:\> Stop-RemoteProcess -ComputerName foo
        This command stops processes on 'foo' computer.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    29/05/2018
        Modified:   17/04/2020
        Version:    1.2
    #>
    
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]        
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
    )
    
    begin
    {
        try
        {
            $processes = Get-Process -ComputerName $ComputerName -ErrorAction Stop | 
                Select-Object @(
                    'ProcessName',
                    'Company',
                    'Description',
                    @{ Name = 'Mem (KB)'; Expression = { [int]($_.WS / 1KB) } },
                    @{ Name = 'CPU'; Expression = { [int]($_.CPU / 1KB) } }, 
                    'ID', 
                    'Path'
                ) | Sort-Object 'ProcessName' | Out-GridView -PassThru -Title 'Select processes'
            
            Write-Verbose -Message 'Getting running processes.'
        }
        catch
        {
            $_.Exception.Message
        }
    }
    
    process
    {
        if ($processes)
        {
            foreach ($process in $processes)
            { 
                try
                {
                    if ($PSCmdlet.ShouldProcess($process.ProcessName, 'Stop Process'))
                    {
                        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                            Stop-Process -Id $using:process.Id -Force -ErrorAction SilentlyContinue
                        }
                    }

                    Write-Verbose -Message "Stopping $process.ProcessName process."
                }
                catch { }
            }
        }  
        else
        {
            Write-Verbose -Message 'No processes have been selected.'
        }    
    }
}