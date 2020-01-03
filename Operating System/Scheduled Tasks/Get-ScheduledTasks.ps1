<#
Name:	     Get-ScheduledTasks
Author:      Daniel Schwitzgebel
Description: Get the list of Schedule Tasks
Created:     18/10/2016
Modified:    18/10/2016
Version:     1.1.0
#>

$servers = Get-ADComputer -Filter 'Name -like "*"'
$tasksList = @()

foreach ($server in $servers.Name)
{
    if (Test-Connection -ComputerName $server -Quiet)
    {

        $scheduledService = New-Object -ComObject Schedule.Service                        
        $scheduledService.Connect($server)                        
        $rootfolder = $scheduledService.GetFolder('\')            
                                
        $tasks = $rootfolder.gettasks(1)
                         
        foreach ($task in $tasks)
        {
            if (-not ($task.Name -like "*Optimize Start Menu Cache*" -or $task.Name -like "*ShadowCopyVolume*" -or $task.Name -like "*User_Feed_Synchronization*"))
            {
                $taskObj = [PSCustomObject]@{
                    ComputerName = $server
                    TaskName     = $Task.Name
                    IsEnabled    = $task.enabled 
                    LastRunTime  = $task.LastRunTime
                    NextRunTime  = $task.NextRunTime
                }
		  
                $tasksList += $taskObj
            }
        }
    }
}

$tasksList | Format-Table | Out-File c:\temp\List-ScheduledTasks.txt