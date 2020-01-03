Function Get-StartUpShutdown
{
  <#
  .SYNOPSIS 
    This function will get the Startup and Shutdown datetime.
  
  .DESCRIPTION 
    This function will get the Startup and Shutdown datetime, for the last daterange.
    Admins right needed to run this script.
  
  .PARAMETER ComputerName 
    A single Computer.
  
  .PARAMETER Months 
    Filters by a range date. Default is last 3 months starting from today.
    Format date is MM/dd/yyyy
    
  .EXAMPLE 
    Get-StartUpShutdown -ComputerName foo -Months 01/11/2013 
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    22/07/2014
    Modified:   10/12/2019
    Version:    1.5
  #>
    
  [OutputType([Selected.System.Diagnostics.EventLogEntry])]
  param( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $ComputerName,
        
    [Parameter()] 
    [ValidateNotNullOrEmpty()]
    [String]
    $Months
  )

  begin
  {
    if ($PSBoundParameters.ContainsKey('Months'))
    {
      [datetime]$Months = (Get-Date).AddMonths(-$($Months))
    }
    else
    {
      [datetime]$Months = (Get-Date).AddMonths(-3)
    }
  }
    
  process
  {
    try
    {
      $getEventLogParams = @{
        ComputerName = $ComputerName
        LogName      = 'System'
        After        = $Months
        Source       = 'Microsoft-Windows-Kernel-General'
        ErrorAction  = 'Stop'
      }
      
      Get-EventLog @getEventLogParams | Where-Object { 
        $_.EventId -eq 12 -or $_.EventId -eq 13;
        $eventid = $_.EventId;
        
        switch ($eventid)
        { 
          12 { $action = 'Startup' } 
          13 { $action = 'Shutdown' }    
        }
        $_ | Add-Member -MemberType NoteProperty -Name Action -Value $action;
      } | Select-Object EventId, Action, TimeGenerated | Sort-Object TimeGenerated
}
    catch
    {
      throw 'Error contacting the host!'
    }
  }
}