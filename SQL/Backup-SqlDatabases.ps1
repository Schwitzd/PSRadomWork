function Backup-SqlDatabases
{
    <#
  .SYNOPSIS 
    Backup all SQL Server databases on an instance, excluding built-in databases.

  .DESCRIPTION
    This function uses the SQL Server module to perform a full backup of all SQL Server databases on a specified instance,
    excluding the built-in databases (master, tempdb, model, msdb).

  .PARAMETER ServerInstance
    The name of the SQL Server instance.

  .PARAMETER BackupDirectory
    The directory where the backup files will be saved.
    
  .EXAMPLE
    PS> Backup-SqlDatabases -ServerInstance 'localhost' -BackupDirectory 'C:\Backup'
    Backs up all databases on the local SQL Server instance, excluding built-in databases,
    and saves the backup files in the 'C:\Backup' directory.

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
        
        $databases = Get-SqlDatabase -ServerInstance $ServerInstance
    }

    process
    {
        foreach ($database in $databases)
        {
            if ($database.Name -notin ('master', 'tempdb', 'model', 'msdb'))
            {
                $backupFileName = "$($database.name).bak"
                $backupFilePath = Join-Path -Path $BackupDirectory -ChildPath $backupFileName
                try
                {
                    $backupSqlDatabaseParam = @{
                        ServerInstance = $ServerInstance
                        Database       = $database.Name
                        BackupFile     = $backupFilePath
                    }

                    Backup-SqlDatabase @backupSqlDatabaseParam
                    Write-Host "Backup of $($database.Name) completed. Backup file saved to $backupFilePath"
                }
                catch
                {
                    Throw $_.Exception.Message
                }
            }
        }    
    }
}