function Get-ShutdownReasons
{
  <#
  .SYNOPSIS 
    Export all shutdown reasons within asked reason.
  
  .DESCRIPTION 
    This Script will export all the shutdown reasons within the asked period in HTML Report.
  
  .PARAMETER ComputerName
    A single Computer name. 
  
  .PARAMETER DayBack
    Dayback for lookup.

  .PARAMETER Destination
    Path to save HTML Report.
    
  .EXAMPLE 
    PS C:\> Get-ShutdownReasons -ComputerName foo -DayBack 30 -Destination 'c:\temp'
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   02/01/2017
    Modified:  10/12/2019
    Version:   1.3
  #>

  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [int]
    $DayBack,
      
    [Parameter(Mandatory)]
    [ValidateScript({ 
        if (-not (Test-Path $_))
        {
          throw 'Destination folder not found!'
        }
      })]
    [String]
    $Destination
  )

  #Requires -RunAsAdministrator

  $htmlReport = "$Destination\$ComputerName" + '_ShutdownReasons.html'

  if (Test-Path $htmlReport)
  {
    Remove-Item $htmlReport
  }

  $getEventLogParams = @{
    ComputerName = $ComputerName
    LogName      = 'System'
    EntryType    = 'Information'
    Source       = 'USER32'
    After        = (Get-Date).AddDays( - ($DayBack))
  }

  $convertToHtmlParams = @{
    Title      = "$ComputerName ShutDown Reasons"
    PreContent = "<h3>$ComputerName ShutDown Reasons</h3>`
                      <h4>for the last $DayBack days</h4>"
    Head       = "<style>`
                      Body    {font-family: Verdana,sans-serif; font-size: 10pt; font-weight: normal;}`
                      table   {font-family: Verdana,sans-serif; font-size: 10pt; font-weight: normal; margin: 0 auto; width:85%; border-collapse: collapse}`
                      th, td  {text-align: left; padding: 8px;}`
                      th      {background-color: #8c8c8c; color: white;}`
                      h3, h4  {Color: #333333;}`
                      tr:nth-child(even) {background-color: #f2f2f2}`
                      </style>" 
  }

  Get-EventLog @getEventLogParams | Where-Object { $_.Message -match 'Shutdown' } | 
    Select-Object EventID, TimeGenerated, Source, Message | 
      ConvertTo-Html @convertToHtmlParams | 
        Out-File $htmlReport

  Invoke-Expression $htmlReport
}