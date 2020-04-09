function Get-Something
{
    <# 
    .SYNOPSIS 
        A brief description of the Get-Something function.
    
    .DESCRIPTION 
        A detailed description of the Get-Something function.
    
    .PARAMETER Foo
        Specifies a single Computer or an array of computer names. Default is localhost. 
    
    .PARAMETER Bar
        Specifies a description of the Path parameter.

    .EXAMPLE 
        PS C:\> Get-Something -ComputerName $value1 -Path $value2
        This command gets all...
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    xx/xx/2020
        Modified:   xx/xx/2020
        Version:    1.0

    .LINK
  #> 

    [OutputType([Void])]
    [CmdletBinding(DefaultParameterSetName = 'Param1')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Foo,
      
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Bar
    )

    begin
    {
        # Used for prep. This code runs one time prior to processing items specified via pipeline input.
    }
 
    process
    {
        # This code runs one time for each item specified via pipeline input.
        try
        {
            
        }
        catch
        {

        }
    }
 
    end
    {
        # Used for cleanup. This code runs one time after all of the items specified via pipeline input are processed.
    }
}