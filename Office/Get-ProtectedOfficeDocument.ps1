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
    
    .PARAMETER Path
        Specifies a single or an array of file/folder. 
    
    .EXAMPLE 
        PS C:\> Get-ProtectedOfficeDocument -Path mydocument.docx
        This command return if the file mydocument.docx is protected by password.

        PS C:\> Get-ProtectedOfficeDocument -Path c:\temp,c:\documents
        This command scan the above folders for Office documents protected by password.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    10/07/2020
        Modified:   10/07/2020
        Version:    2.0

    .LINK
  #> 

    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()] 
        [String[]]
        $Path
    )

    function Test-ProtectedOfficeFile 
    {
        param (
            [String]
            $Path
        )

        $binary = Get-Content -Path $Path -AsByteStream | Select-Object -First 2000
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
    $officeFiles = [System.Collections.ArrayList]@()

    foreach ($p in $Path)
    {
        if (Test-Path -LiteralPath $p)
        {
            if ((Get-Item -LiteralPath $p) -is [System.IO.DirectoryInfo])
            {
                $files = Get-ChildItem -Path $p -Include $officeExtensions -Recurse
                [void]$officeFiles.AddRange($files)
            }
            elseif ((Get-Item -LiteralPath $p) -is [System.IO.FileInfo])
            {
                [void]$officeFiles.add($p)
            }
        }
    }

    $officeFiles | ForEach-Object -Process {
        $result = Test-ProtectedOfficeFile -Path $_

        [PSCustomObject]@{
            FileName  = $_
            Protected = $result
        }
    }
}