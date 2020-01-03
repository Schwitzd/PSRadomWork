function Resolve-ShortURL {
	<#
	.SYNOPSIS
		Function to resolve a short URL to the absolute URI.
		
	.DESCRIPTION
		Function to resolve a short URL to the absolute URI.
		
	.PARAMETER ShortUrl
		Specifies the ShortURL

	.EXAMPLE
		Resolve-ShortURL -ShortUrl http://goo.gl/P5PKq

	.NOTES 
		Author:		Daniel Schwitzgebel
		Created:	07/08/2016
		Modified:	08/08/2016
		Version:	1.0
	#>
	
	[CmdletBinding()]
	[OutputType([System.String])]
	param(
		[String[]]$ShortUrl
	)
	
	Foreach ($URL in $ShortUrl){
		Try
		{
			(Invoke-WebRequest -Uri $URL -MaximumRedirection 0 -ErrorAction Ignore).Headers.Location
		}
		Catch
		{
			throw 'URL not resolved'
		}
	}
}