function Get-ComputerUUID
{
  <#
  .SYNOPSIS 
    This function will get the computer UUID.
  
  .DESCRIPTION 
    This function will get the computer UUID by querying wmi.
  
  .PARAMETER ComputerName 
    ComputerName to get UUID
    
  .EXAMPLE 
    Get-ComputerUUID -ComputerName foo
  
  .NOTES 
    Author:   Daniel Schwitzgebel 
    Created:  27/04/2012
    Modified: 27/12/2019
    Version:  1.3
    Changes:  1.1   Change  - Hostname to ComputerName and improved parameter
              1.2   Change  - Code Refactoring and applied PS Best Practice and Style Guide
                    Change  - Ping Test with Test-Connection cmdlet
                    Change  - Replace WMI with CIM
              1.3   Change  - Code style refactoring  
  #>

  [CmdletBinding()] 
  param( 
    [Parameter(Mandatory)] 
    [String[]]
    $ComputerName
  )

  process
  {
    foreach ($c in $ComputerName)
    {
      try
      {
        $getCimInstanceParams = @{
          ComputerName = $c
          ClassName    = 'Win32_ComputerSystemProduct'
          ErrorAction  = 'Stop'
        }

        $uuid = Get-CimInstance @getCimInstanceParams | Select-Object -ExpandProperty UUID

        [pscustomobject]@{
          ComputerName = $c
          UUID         = $uuid
        }

      }
      catch
      {
        continue
      }
    }
  }
}