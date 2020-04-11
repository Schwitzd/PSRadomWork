function Update-StringInFile
{
	<#
	.SYNOPSIS
		Replace a string in one or multiple files.
					
	.DESCRIPTION         
		Replace a string in one or multiple files. Binary file not touched by this script.

	.PARAMETER CaseSensitive
		Specifies if the string must be case sensitive, default is false.

	.PARAMETER Find
		Specifies the string to find.

	.PARAMETER Path
		Specifies the folder where the files are stored, will search recursive.

	.PARAMETER ReplaceWith
		Specifies the string to replace.
								
	.EXAMPLE
		PS C:\> Update-StringInFile -Path E:\Temp\Files\ -Find 'Test1' -ReplaceWith 'Test2' -Verbose
		This command replace the string 'Test1' with 'Test2' in verbose mode.

	.NOTES 
		Author:		Daniel Schwitzgebel
		Created:	19/08/2016
		Modified: 	11/04/2020  
		Version: 	1.2.1
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter()]
		[switch]
		$CaseSensitive = $false,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]
		$Find,

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
		$ReplaceWith
	)

	process
	{
		Write-Verbose -Message 'Binary files like are ignored'

		$files = Get-ChildItem -Path $Path -Recurse | 
			Where-Object { ($_.PSIsContainer -eq $false) -and ((Test-IsFileBinary -Path $_.FullName) -eq $false) } | 
				Select-String -Pattern ([regex]::Escape($Find)) -CaseSensitive:$CaseSensitive | 
					Group-Object Path 
		
	Write-Verbose -Message "Total files with string to replace found: $($Files.Count)"

	foreach ($file in $files)
 {
		Write-Verbose -Message "File:`t$($file.Name)"
		Write-Verbose -Message "Number of strings to replace in current file:`t$($file.Count)"
		
		try
		{
			if ($CaseSensitive)
			{
				(Get-Content -Path $File.Name) -creplace [regex]::Escape($Find), $ReplaceWith | 
					Set-Content -Path $File.Name -Force
			}
			else
			{
				(Get-Content -Path $File.Name) -replace [regex]::Escape($Find), $ReplaceWith | 
					Set-Content -Path $File.Name -Force
			}
		}
		catch
		{
			throw $_.Exception.Message
		}
	}
}
}