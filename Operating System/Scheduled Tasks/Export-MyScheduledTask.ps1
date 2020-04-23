function Export-MyScheduledTask 
{
    <#
    .SYNOPSIS 
        This function will export scheduled tasks.
  
    .DESCRIPTION 
        This function will export scheduled tasks created by a domain user to XML format.

    .PARAMETER Name
        Specifies the name of the tasks.
  
    .PARAMETER Path 
        Specifies the path to export the XML.
    
    .EXAMPLE 
        PS C:\> Export-MyScheduledTask -Path 'c:\temp'
        This command exports all scheduled tasks.
  
    .NOTES
        Author:    Daniel Schwitzgebel
        Created:   27/04/2012
        Modified:  11/04/2020
        Version:   1.0
  #>

    [OutputType([Void])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [String[]]
        $Name,

        [Parameter(Mandatory)]
        [String]
        $Path
    )
    
    $getScheduledTaskParam = @{}

    if ($PSBoundParameters.ContainsKey('Name'))
    {
        $getScheduledTaskParam = @{
            TaskName = $Name
        }

    }

    $tasks = Get-ScheduledTask @getScheduledTaskParam | 
        Where-Object { $_.Author -like "$env:USERDOMAIN\*" -and $_.TaskName -notlike "User_Feed_Synchronization*" }

    foreach ($task in $tasks)
    {
        $exportScheduledTaskParam = @{
            TaskName = $task.TaskName
            TaskPath = $task.TaskPath
        }
        
        Export-ScheduledTask @exportScheduledTaskParam | Out-File -FilePath "$Path\$($task.TaskName).xml"
        Write-Verbose -Message "Exporting task $($task.TaskName)"
    }

}