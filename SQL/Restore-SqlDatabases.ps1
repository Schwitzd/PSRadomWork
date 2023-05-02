function Restore-SqlDatabases
{
  <#
  .SYNOPSIS
    Restores SQL Server databases from backup files.

  .DESCRIPTION
    This function restores SQL Server databases from backup files.

  .PARAMETER ServerInstance
    The name of the SQL Server instance.

  .PARAMETER BackupDirectory
    The directory where the backup files will be saved.
    
  .EXAMPLE
    Restore-SqlDatabases -ServerInstance 'foo' -BackupDirectory 'C:\Backup'
    This example restores all SQL Server databases from the backup files located in the 'C:\Backup' directory on the foo server.

  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    11/04/2023
    Modified:   11/04/2023
    Version:    1.0
  #>
  
  [OutputType([void])]    
  param (
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ServerInstance,

    [parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $BackupDirectory
  )

  begin
  {
    try
    {
      Import-Module -Name SqlServer
    }
    catch
    {
      Throw $_.Exception.Message
    }
        
    $backupFiles = Get-ChildItem -Path $BackupDirectory -Filter *.bak
  }

  process
  {
    foreach ($backupFile in $backupFiles)
    {
      $databaseName = $backupFile.Name -replace '.bak$'
      $backupFilePath = Join-Path -Path $BackupDirectory -ChildPath $backupFile.Name

      try
      {
        $restoreSqlDatabaseParam = @{
          ServerInstance   = $ServerInstance
          Database         = $databaseName
          BackupFile       = $backupFilePath
          AutoRelocateFile = $true
        }

        Restore-SqlDatabase @restoreSqlDatabaseParam
      }
      catch
      {
        Throw $_.Exception.Message
      }

      Write-Host "Database $databaseName has been restored from $backupFilePath"
    } 
  }
}