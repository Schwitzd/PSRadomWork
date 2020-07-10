function Get-ProtectedOfficeDocument
{
    <# 
    .SYNOPSIS 
        This function will get the list of Microsoft Office documents protected with password.
    
    .DESCRIPTION 
        This function will gets the list of Microsoft Office documents protected with password.
        It is possible to choose a specific files or a bunch of folders.
        The detection is done by reading the first 2 Bytes of the file.
        Supported Office programs: Word, Excel, PowerPoint, Visio, Access, Publisher
    
    .PARAMETER File
        Specifies a single or an array of file. 
    
    .PARAMETER Folder
        Specifies a single or an array of folders. 

    .EXAMPLE 
        PS C:\> Get-ProtectedOfficeDocument -File mydocument.docx
        This command return if the file mydocument.docx is protected by password.

        PS C:\> Get-ProtectedOfficeDocument -Folder c:\temp,c:\documents
        This command scan the above folders for Office documents protected by password.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    10/07/2020
        Modified:   10/07/2020
        Version:    1.0

    .LINK
  #> 

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(ParameterSetName = 'File')]
        [ValidateNotNullOrEmpty()] 
        [String[]]
        $File,
      
        [Parameter(ParameterSetName = 'Folder')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Folder
    )

    function Test-ProtectedOfficeFile 
    {
        param (
            [String]
            $FileName
        )

        $binary = Get-Content -Path $FileName -AsByteStream | Select-Object -First 2000
        $string = [System.Text.Encoding]::Default.GetString($binary)

        if ($string -match "E.n.c.r.y.p.t.e.d.P.a.c.k.a.g.e")
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    $officeExtensions = @("*.do*", "*.xl*", "*.pp*", "*.po*", "*.accd*", "*.md*", "*.vsd*", "*.pub")
        
    if ($psCmdlet.ParameterSetName -eq 'File')
    {
        foreach ($f in $File)
        {
            if (Test-Path -Path $f)
            {
                if ($officeExtensions | Where-Object { [IO.Path]::GetExtension($f) -like $_ })
                {
                    $result = Test-ProtectedOfficeFile -FileName $f

                    [PSCustomObject]@{
                        FileName  = $f
                        Protected = $result
                    }
                }
            }
        }
    }
    else 
    {
        foreach ($f in $Folder)
        {
            if (Test-Path -Path $f)
            {
                Get-ChildItem -Path $f -Include $officeExtensions -Recurse | ForEach-Object -Process {
                    $result = Test-ProtectedOfficeFile -FileName $_.FullName

                    [PSCustomObject]@{
                        FileName  = $_.FullName
                        Protected = $result
                    }
                }
            }
        }
    }
}