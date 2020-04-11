function Resolve-ShortURL {
	<#
	.SYNOPSIS
		Function to resolve a short URL to the absolute URI.
		
	.DESCRIPTION
		Function to resolve a short URL to the absolute URI.
		
	.PARAMETER ShortUrl
		Specifies the short URL link.

	.EXAMPLE
		PS C:\> Resolve-ShortURL -ShortUrl http://goo.gl/P5PKq
		This command gets the absolute URI for the given URL.

	.NOTES 
		Author:		Daniel Schwitzgebel
		Created:	07/08/2016
		Modified:	11/04/2020
		Version:	1.0.1
	#>
	
	[CmdletBinding()]
	[OutputType([System.String])]
	param (
		[String[]]
		$ShortUrl
	)
	
	foreach ($url in $ShortUrl){
		try
		{
			(Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction Stop).Headers.Location
		}
		catch
		{
			throw 'URL not resolved'
		}
	}
}