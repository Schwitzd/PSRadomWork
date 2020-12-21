Function Get-UserLogon
{
  <#
  .SYNOPSIS 
    This function will get the logged in user in specific computer.
  
  .DESCRIPTION 
    This function will get the logged in user in specific computer, query is done with WinRM,
    then a cross check is done with active directory.
  
  .PARAMETER ComputerName 
    Specified the computer name to check the logged in user.

  .PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default value is the current user.
    
  .EXAMPLE 
    PS C:\> Get-UserLogon -ComputerName foo
    This command get the users sessions for a given computer name.
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   10/03/2018
    Modified:  07/12/2020
    Version:   1.3.0
  #>
  
  [OutputType([System.Management.Automation.PSCustomObject])] 
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $ComputerName,

    [Parameter()]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty
  )
  
  begin
  {
    $result = @()
    $invokeCommandParams = @{
      ComputerName = $ComputerName
      ScriptBlock  = { quser }
    }

    if ($Credential -ne [System.Management.Automation.PSCredential]::Empty)
    {
      $invokeCommandParams['Credential'] = $Credential
    }
  }

  process
  {
    try
    {
      Invoke-Command @invokeCommandParams | Select-Object -Skip 1 | ForEach-Object {
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
    }
    catch
    {
      throw $_.Exception.Message
    }
  }

  end
  {
      Write-Output $result
  }
}