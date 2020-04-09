function Get-Something
{
  <# 
    .SYNOPSIS 
        A brief description of the Get-Something function.
    
    .DESCRIPTION 
        A detailed description of the Get-Something function.
    
    .PARAMETER ComputerName
        Specifies a single Computer or an array of computer names. Default is localhost. 
    
    .PARAMETER Path
        Specifies a description of the Path parameter.
      
    .EXAMPLE 
        PS C:\> Get-Something -ComputerName $value1 -Path $value2
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    xx/xx/2020
        Modified:   xx/xx/2020
        Version:    1.0

    .LINK
  #> 

    param (
        [Parameter(Mandatory)] 
        [String]
        $ComputerName,
      
        [Parameter()] 
        [String]
        $Path
    )
}