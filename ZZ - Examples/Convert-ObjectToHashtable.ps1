function Convert-ObjectToHashtable
{
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $object,

        [Switch]
        $ExcludeEmpty
    )

    process
    {
        $object.PSObject.Properties | 
        Sort-Object -Property Name |
        Where-Object { $ExcludeEmpty.IsPresent -eq $false -or $null -ne $_.Value } |
        ForEach-Object { $hashtable = [Ordered]@{ } } { $hashtable[$_.Name] = $_.Value } { $hashtable }
    }
} 