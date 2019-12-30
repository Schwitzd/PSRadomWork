function Update-StringInFile
{
	<#
	.SYNOPSIS
	Replace a string in one or multiple files.
					
	.DESCRIPTION         
	Replace a string in one or multiple files. Binary file not touched by this script.

	.PARAMETER Path
	Folder where the files are stored, will search recursive.

	.PARAMETER Find
	String to find.

	.PARAMETER ReplaceWith
	String to replace.

	.PARAMETER CaseSensitive
	String must be case sensitive, default is false.
								
	.EXAMPLE
	Update-StringInFile -Path E:\Temp\Files\ -Find 'Test1' -ReplaceWith 'Test2' -Verbose

	.NOTES 
	Author:		Daniel Schwitzgebel
	Created:	19/08/2016
	Modified: 	29/11/2019  
	Version: 	1.2
	Changes:   	1.1		Add    - Added Validator for Path Parameter
				1.2		Change - Code
	#>

	[CmdletBinding(SupportsShouldProcess)]
	Param(
		[Parameter(Mandatory)]
		[ValidateScript( {
				if (-not (Test-Path -Path $_))
				{
					throw 'Enter a valid path!'
				}
			})]
		[String]
		$Path,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]
		$Find,
	
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]
		$ReplaceWith,

		[Parameter()]
		[switch]
		$CaseSensitive = $false
	)

	process
	{
		Write-Verbose -Message 'Binary files like are ignored'

		$files = Get-ChildItem -Path $Path -Recurse | 
			Where-Object { ($_.PSIsContainer -eq $false) -and ((Test-IsFileBinary -Path $_.FullName) -eq $false) } | 
				Select-String -Pattern ([regex]::Escape($Find)) -CaseSensitive:$CaseSensitive | Group-Object Path 
		
	Write-Verbose -Message "Total files with string to replace found: $($Files.Count)"

	foreach ($file in $files)
 {
		Write-Verbose -Message "File:`t$($file.Name)"
		Write-Verbose -Message "Number of strings to replace in current file:`t$($file.Count)"
		
		try
		{
			if ($CaseSensitive)
			{
				(Get-Content -Path $File.Name) -creplace [regex]::Escape($Find), $ReplaceWith | Set-Content -Path $File.Name -Force
			}
			else
			{
				(Get-Content -Path $File.Name) -replace [regex]::Escape($Find), $ReplaceWith | Set-Content -Path $File.Name -Force
			}
		}
		catch
		{
			throw $_.Exception.Message
		}
	}
}
}