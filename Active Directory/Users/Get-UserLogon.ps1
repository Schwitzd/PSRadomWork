Function Get-UserLogon
{
  <#
  .SYNOPSIS 
    This function will get the logged in user in specific computer.
  
  .DESCRIPTION 
    This function will get the logged in user in specific computer, query is done with WinRM,
    then a cross check is done with active directory.
    Admin right are required to run this script!
  
  .PARAMETER ComputerName 
    ComputerName to check the logged in user.
    
  .EXAMPLE 
    Get-UserLogon -ComputerName foo.
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   10/03/2018
    Modified:  10/12/2019
    Version:   1.2
  #>
  
  [OutputType([System.Management.Automation.PSCustomObject])] 
  param( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $ComputerName
  )
  
  $result = @()
  if (Test-NetConnection -ComputerName $ComputerName -InformationLevel Quiet)
  {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { quser } | Select-Object -Skip 1 | ForEach-Object {
      $a = $_.trim() -replace '\s+', ' ' -replace '>', '' -split '\s'
      
      if ($a[2] -like '*Disc*')
      {
        $array = ([ordered]@{
            'Username'     = $a[0]
            'Name'         = (Get-ADUser -Identity $a[0] -Properties DisplayName).DisplayName
            'Session Name' = 'N/A'
            'State'        = $a[2]
            'Idle Time'    = $a[3]
            'Logon Time'   = $a[4..6] -join ' '
          })
 
        $result += New-Object -TypeName PSCustomObject -Property $array
      }
      else
      {
        $array = ([ordered]@{
            'Username'     = $a[0]
            'Name'         = (Get-ADUser -Identity $a[0] -Properties DisplayName).DisplayName
            'Session Name' = $a[1]
            'State'        = $a[3]
            'Idle Time'    = $a[4]
            'Logon Time'   = $a[5..7] -join ' ' 
          })
        $result += New-Object -TypeName PSCustomObject -Property $array
      }
    }
    Write-Output $result
  }
}