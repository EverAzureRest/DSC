Configuration SQLStandalone
{

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xSQLServer -Name xSQLServerSetup,xSQLServerDatabaseRole
Import-DscResource -ModuleName xStorage

$sqlsetupcred = Get-AutomationPSCredential -Name "sqlstandalonesetup"
$storageCredential = Get-AutomationPSCredential -Name "eus2storageaccount"
$tempdir = "C:\Temp"
$storageaccountname = Get-AutomationVariable -Name "saname"
$datadriveletter = "F"
$tempdbdriveletter = "T"


Node $AllNodes.NodeName {
    WindowsFeature Net-Framework-45-Core
        {
            Ensure = "Present"
            Name = "Net-Framework-45-Core"
        }
    WindowsFeature Net-Framework-Core
        {
            Name = 'Net-Framework-Core'
            Ensure = 'Present'
        }
    File SQLBinary
    {
        DestinationPath = "$tempdir\sqlinstall\source"
        Credential = $storageCredential
        Ensure = "Present"
        SourcePath = "\\$($storageaccountname).file.core.windows.net\eaus2share\sql14"
        Type = "Directory"
        Recurse = $true
    }
    xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = 60
            RetryCount = 60
        }
    xWaitforDisk Disk3
        {
            DiskNumber = 3
            RetryIntervalSec = 60
            RetryCount = 60
        }
    xDisk FVolume
        {
            DiskNumber = 3
            Driveletter = $datadriveletter
            FSLabel = 'Data'
        }
    xDisk TVolume
        {
            DiskNumber = 2
            DriveLetter = $tempdbdriveletter
            FSLabel = 'TempDB'
        }
 
    xSQLServerSetup Staged
        {
        InstanceName = 'MSSQLServer'
        SetupCredential = $sqlsetupcred
        InstallSQLDataDir = 'F:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
        SourcePath = "$tempdir\sqlinstall"
        SQLSvcAccount = $svcAccount
        SQLTempDBDir = 'T:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\TEMPDB'
        SQLTempDBLogDir = 'T:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\TEMP\LOG'
        SQLUserDBDir = 'F:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
        SQLUserDBLogDir = 'F:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\LOG'
        UpdateEnabled = $true
        Features = "SQLENGINE"
        Dependson = '[xDisk]FVolume','[xDisk]TVolume','[WindowsFeature]Net-Framework-45-Core','[WindowsFeature]Net-Framework-Core'
        }


}





}