# File Systems

## ACLs

* **Get-aclGroups** - Get all ACL Groups for a Directory and its subfolders
* **Get-ACLNotInheritPermissions** - Get all paths with not Inherit Permissions
* **Get-ACLTree** - Get all ACL groups for a Directory Path in tree view
* **Get-FoldersWithoutAccess** - Get all Folders with Access Denied.

## Files

* **Find-LockedFileProcess** - This function help track down a process that is locking down a file you are trying access
* **Get-FilesOlderThan** - Returns files from within a directory and optionally subdirectories that are older than a specified period
* **Get-RecentModifiedFiles** - Get most recent modified files in a folder structure
* **Invoke-BitsTransferAsynchronous** - This cmdlet create a BITS transfer job to transfer a file between a client and a server.
* **New-DummyFile** - This function create a dummy file with a custom size
* **Update-StringInFile** - Replace a string in one or multiple files

## Folders

* **Get-LongPathNames** - This function will get the list of file and folder with long path
* **Get-SharedFolder** - Create a new shared folder with share permission

## Shares

* **New-BulkShares** - Based on input JOSN file multiple share are created

## VSS

* **Get-VssWriters** - Get the list of VSS writers
* **Restart-VssWriters** - This function restart a list of specified VSS writers
  