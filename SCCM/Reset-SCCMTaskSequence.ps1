function Reset-SCCMTaskSequence
{
    <#
	.SYNOPSIS 
		This function will reset the SCCM Client Task Sequence.
 
	.DESCRIPTION 
        This function will reset the SCCM Client Task Sequence, useful when Software Center
        show application in "Installing/Downloading" state but nothing is really happening.

    .PARAMETER ComputerName
        Specifies the computer name
  
	.EXAMPLE 
		PS C:\> Reset-SCCMTaskSequence -ComputerName foo
		This command resets the SCCM Client Task Sequence.
 
	.NOTES 
		Author:		Daniel Schwitzgebel
		Created:	12/11/2020
		Modified:	12/11/2020
		Version:	1.0.0
    #>
    
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName       
    )

    if ($PSCmdlet.ShouldProcess("SCCM Client on $ComputerName", 'Reset Task Sequence'))
    {
        $getCimInstanceParam = @{
            ComputerName = $ComputerName
            Namespace    = 'root/ccm'
            ClassName    = 'SMS_MaintenanceTaskRequests'
        }

        $tasksRequests = Get-CimInstance @getCimInstanceParam

        if ($tasksRequests)
        {
            Remove-CimInstance -CimInstance $tasksRequests
            Write-Verbose -Message "Found $($tasksRequests.Count) maintenance task requests."
            Write-Verbose -Message 'Deleting maintenance mask requests.'
        }

        $getCimInstanceParam = @{
            ComputerName = $ComputerName
            Namespace    = 'Root\CCM\SoftMgmtAgent'
            ClassName    = 'CCM_TSExecutionRequest'
        }

        $tsExecutionRequest = Get-CimInstance @getCimInstanceParam

        if ($tsExecutionRequest)
        {
            Remove-CimInstance -CimInstance $tsExecutionRequest
            Write-Verbose -Message "Found $($tasksRequests.Count) active task requests."
            Write-Verbose -Message 'Deleting active task sequences.'
        }

        $null = Restart-Service -Name 'CcmExec' -Force
    }
}