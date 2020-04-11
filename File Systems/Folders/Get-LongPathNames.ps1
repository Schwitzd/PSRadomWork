function Get-LongPathNames
{
  <#
  .SYNOPSIS 
    This function will get the list of file and folder with long path.
  
  .DESCRIPTION 
    This function will parse the output of Robocopy to get the list of file and folder with long path.
  
  .PARAMETER FolderPath 
    Specifies the path to parse.

  .PARAMETER MaxDepth 
    Specifies the maximum character length to discover, default is 248.
    
  .EXAMPLE 
    PS C:\> Get-LongPathNames -FolderPath M:\Data -MaxDepth 255
    This command gets the paths longer then 255 charapters.
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    18/04/2016
    Modified:   25/08/2016
    Version:    1.0

  .LINK
    http://www.powershellmagazine.com/2012/07/24/jaap-brassers-favorite-powershell-tips-and-tricks/
    https://learn-powershell.net/2013/04/01/list-all-files-regardless-of-260-character-path-restriction-using-powershell-and-robocopy/  
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string[]]
    $FolderPath,

    [ValidateRange(10, 260)]
    [int16]
    $MaxDepth = 248
  )

  begin
  {
    if (-not (Test-Path -Path $(Join-Path $env:SystemRoot 'System32\robocopy.exe')))
    {
      throw 'Robocopy not found, please install robocopy'
    }
    $results = @()
  }

  process
  {
    foreach ($path in $FolderPath)
    {
      $roboOutput = robocopy.exe $Path c:\doesnotexist /l /e /b /np /fp /njh /njs
      $roboOutput | Select-String 'New File' | Where-Object { $_.Line.Length -ge $MaxDepth + 26 } | ForEach-Object {
        $props = @{
          FullPath   = $_.Line.Substring(26, $_.Line.Length - 26)
          Type       = 'File'
          PathLength = $_.Line.Length - 26
        }
        $results += New-Object -TypeName PSCustomObject -Property $props
      }
      # Append folders to array
      $roboOutput | Select-String 'New Dir' | Where-Object { $_.Line.Length -ge ($MaxDepth + 22) } | ForEach-Object {
        $props = @{
          FullPath   = $_.Line.Substring(22, $_.Line.Length - 22)
          Type       = 'Folder'
          PathLength = $_.Line.Length - 22
        }
        $results += New-Object -TypeName PSCustomObject -Property $props
      }
    }
  }
  
  end
  {
    $results | Format-Table * -AutoSize | Out-String -Width 500 | Out-File 'c:\temp\LongPathNames.log'
    Write-Output 'Log in c:\temp\LongPathNames.log'
  }
}