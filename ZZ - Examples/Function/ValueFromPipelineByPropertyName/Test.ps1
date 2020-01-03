function Test-ScriptBlock
{
  [CmdletBinding()]
  param
  (

    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline)]
    [string]
    $Par1,

   

    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Par2
  )


  begin 
  {
    Write-Warning "Starting..."
  }

  process
  {
    Write-Warning "Processing Par1=$Par1 and Par2=$Par2"
  }

  end
  {
    Write-Warning "Ending..."
  }
}