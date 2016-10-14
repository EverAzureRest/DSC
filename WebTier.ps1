Configuration WebTier
{
Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xNetworking
Import-DscResource -ModuleName xWebDeploy
Import-DscResource -ModuleName cAzureStorage
Import-DSCResource -ModuleName xWebAdministration

$tempdir = "C:\Temp"
$storagekey = Get-AutomationVariable -Name "sakey"
$storageaccountname = Get-AutomationVariable -Name "saname"
$destpath = "C:\inetpub\wwwroot\WebApp"

Node WebServer
    {
    WindowsFeature Web-Server
        {
            Ensure = 'Present'
            Name = 'Web-Server'
            IncludeAllSubFeature = $True
        }
        
    WindowsFeature AspNet45
        {
            Ensure                  = 'Present'
            Name                    = 'Web-Asp-Net45'
        }

    xFirewall Default
        {
            Name                  = 'Default'
            Enabled               = 'True'
            Protocol              = 'TCP'
            LocalPort             = '80'
            Action                = 'Allow'
            Profile               = 'Any'
        }
        
     xWebsite DefaultSite 
        {
            Ensure                  = 'Present'
            Name                    = 'Default Web Site'
            State                   = 'Started'
            PhysicalPath            = 'C:\inetpub\wwwroot'
            DependsOn               = '[WindowsFeature]Web-Server'
        }
        
    xWebAppPool WebAppPool
        {

            Ensure                  = 'Present'
            Name                    = 'WebAppPool'
            DependsOn               = '[WindowsFeature]Web-Server'
        }
    
    File WebContent
        {
            Ensure                  = 'Present'
            SourcePath              = 'C:\inetpub\wwwroot'
            DestinationPath         = $destpath
            Recurse                 = $true
            Type                    = 'Directory'
            DependsOn               = '[WindowsFeature]Web-Server'
        }
    
    xWebApplication WebApplication 
        {
            Ensure                  = 'Present'
            Name                    = 'WebApplication'
            WebAppPool              = 'SampleAppPool'
            Website                 = 'Default Web Site'
            PreloadEnabled          = $true
            ServiceAutoStartEnabled = $true
            PhysicalPath            = $destpath
            DependsOn               = '[xWebsite]DefaultSite','[xWebAppPool]WebAppPool'

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
            StorageAccountContainer = 'demoapp'
            StorageAccountKey = $storagekey
            StorageAccountName = $storageaccountname
            DependsOn = '[File]Tempdir'
        }

    Package WebDeploy
        {
            Name = 'Microsoft Web Deploy 3.0'
            Path = "$($tempdir)\WebDeploy_amd64_en-US.msi"
            ProductID = 'AA72C306-30BE-4BB1-9E42-59552BAD2CDF'
            Ensure = 'Present'
        }
    xWebPackageDeploy WebApplication
        {
            Destination = $destpath
            SourcePath = "$($tempdir)\WebApplication.zip"
            Ensure = 'Present'
            DependsOn = '[Package]WebDeploy','[cAzureStorage]WebDeployFile','[xWebApplication]WebApplication'
        }
    }
}