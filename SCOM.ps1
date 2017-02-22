Configuration SCOM
{

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName cAzureStorage
Import-DscResource -ModuleName cChoco

$tempdir = "C:\Temp"
$storagekey = Get-AutomationVariable -Name "sakey"
$storageaccountname = Get-AutomationVariable -Name "saname"

Node MgmtServer
{

    WindowsFeature Net-Framework-45-Core
        {
            Ensure = 'Present'
            Name = 'Net-Framework-45-Core'
        }
    File Tempdir
        {
            DestinationPath = $tempdir
            Ensure = 'Present'
            Type = 'Directory'
        }
    cAzureStorage WebDeployFile
        {
            Path = $tempdir
            StorageAccountContainer = 'scom'
            StorageAccountKey = $storagekey
            StorageAccountName = $storageaccountname
            DependsOn = '[File]Tempdir'
        }

}

Node WebConsole
    {

    WindowsFeature Web-Server
        {
            Ensure = 'Present'
            Name = 'Web-Server'
            IncludeAllSubFeature = $True
        }
    WindowsFeature Net-Framework-45-Core
        {
            Ensure = 'Present'
            Name = 'Net-Framework-45-Core'
        }
    WindowsFeature AspNet45
        {
            Ensure = 'Present'
            Name = 'Web-Asp-Net45'
            DependsOn = '[WindowsFeature]Web-Server','[WindowsFeature]Net-Framework-45-Core'
        }
    WindowsFeature HTTPActivation
        {
            Ensure = 'Present'
            Name = 'NET-WCF-HTTP-Activation45'
            DependsOn = '[WindowsFeature]Net-Framework-45-Core'
        
        }
    File Tempdir
        {
            DestinationPath = $tempdir
            Ensure = 'Present'
            Type = 'Directory'
        }
    cAzureStorage WebDeployFile
        {
            Path = $tempdir
            StorageAccountContainer = 'scom'
            StorageAccountKey = $storagekey
            StorageAccountName = $storageaccountname
            DependsOn = '[File]Tempdir'
        }
    cChocoInstaller installChoco
        {
        InstallDir = "c:\choco"
        }
    cChocoPackageInstallerset AppDeps
        {
            Name = "sql2014.clrtypes"
            Ensure = 'present'
            DependsOn = '[cChocoInstaller]installChoco'
        }
    Package ReportViewer
        {
            Name = 'Microsoft Report Viewer 2015 Runtime'
            Path = "$($tempdir)\ReportViewer.msi"
            ProductID = '3ECE8FC7-7020-4756-A71C-C345D4725B77'
            Ensure = 'Present'
        }
    
    }

}