Configuration Domain
{
    param (
        [Parameter(Mandatory)]
        [String]$domain
    )


Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DscResource -ModuleName xActiveDirectory
Import-DscResource -ModuleName xStorage


$datadriveletter = "F"
$dbpath = "F:\NTDS"
$logpath = "F:\LOGS"
$sysvol = "F:\SYSVOL"
$sfmpass = Get-AutomationPSCredential -Name "adrscred"
$dacred = Get-AutomationPSCredential -name "powerhellda"
$netbiosname = "LAB"

Node $AllNodes.Nodename
    {
    WindowsFeature AD-Domain-Services 
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"    
        }
    WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }
    xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = 60
            RetryCount = 60
        }
    xDisk FVolume
        {
            DiskNumber = 2
            Driveletter = $datadriveletter
            FSLabel = 'Data'
        }
    xADDomain Domain-Build
        {
        DomainAdministratorCredential = $dacred
        DomainName = $domain
        SafeModeAdministratorPassword = $sfmpass
        DomainNetbiosName = $netbiosname
        DatabasePath = $dbpath
        LogPath = $logpath
        SysvolPath = $sysvol
        DependsOn = '[xDisk]FVolume', '[WindowsFeature]AD-Domain-Services'
        }
    }

}