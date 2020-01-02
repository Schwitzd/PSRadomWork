function Get-FilesOlderThan
{
  <#
  .SYNOPSIS 
    Gets files older than a specified age.

  .DESCRIPTION
    Returns files from within a directory and optionally subdirectories that are older than a specified period.

  .PARAMETER Path
    Specifies the path the function should begin searching.
    
  .PARAMETER Days
    Specifies the number of days to find files older than.

  .PARAMETER Filter 
    Specifies the file types to be included in the search, by default all file types are 
    included however this can be filtered by supplying an array of file extensions to include.

  .PARAMETER Top
    Specifies the Top X bigger file to find.

  .PARAMETER Unit
    Specifies the Unit to convert the size of files, the value are ('KB', 'MB', 'GB') by default is KB.
    
  .PARAMETER Log
    log the output to a file, location is 'c:\temp\FilesOlderThan.log'.

  .EXAMPLE 
    PS C:\> Get-FilesOlderThan -Path E:\data -Days 360 -Top 10
    This command returns the top 10 biggest files older than 360 days.

  .EXAMPLE 
    PS C:\> Get-FilesOlderThan -Path E:\data -Days 80 -Unit GB -Log
    This command returns the files older than 80 days the size is in GB and create a log in C:\temp.

  .EXAMPLE
    PS C:\> Get-FilesOlderThan -Path E:\data -Days 60 -Filter *.pptx, *.docx
    This command filter the files by extension and returns the files older than 60 days

  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    27/11/2012
    Modified:   02/01/2020
    Version:    1.2
    Updates:    1.1   Add	    - Created Function
                      Change  - Improved Cmdlets parameters
                1.2   Change  - Code restyle
                      Change  - wrong operator parameter for filter by date
                      Change  - Replaced duplicated code block with a splat
  #>

  [CmdletBinding()] 
  [OutputType([Object])]    
  param( 
    [parameter(ValueFromPipeline)] 
    [string[]]
    $Path,

    [parameter()] 
    [string[]]
    $Filter,
        
    [parameter(Mandatory)]
    [string]
    $Days,
        
    [parameter()] 
    [string]
    $Top, 
        
    [parameter()] 
    [ValidateSet('KB', 'MB', 'GB')] 
    [string]
    $Unit = 'KB',

    [parameter()]  
    [switch]
    $Log = $false
  )

  begin
  {
    if (-not(Test-Path $path))
    { 
      throw "Cannot find the path $path because it does not exist"
    }
    
    $selectObjectSplat = @{ }
    $date = (Get-Date).AddDays(-$Days)
  }

  process
  {       
    if ($Top)
    {
      $selectObjectSplat['First'] = $Top
    }
    
    $files = Get-ChildItem $path -Include $Filter -Recurse | 
      Where-Object { $_.LastWriteTime -ge $date } |
        Sort-Object -Property length -Descending |
          Select-Object @selectObjectSplat |
            Format-Table -AutoSize FullName, 
            @{ Label = "Size ($Unit)"; Expression = { "{0:N2}" -f ($_.length / "1$Unit") } }
  }

  end
  {
    if ($log)
    {
      $logpath = 'c:\temp\FilesOlderThan.log'
      $files | Out-File -FilePath $logpath -Force
    }

    Write-Output $files
  }
}