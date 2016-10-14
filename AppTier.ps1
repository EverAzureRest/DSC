Configuration AppTier
{
Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DscResource -ModuleName cChoco

Node AppServer
    {
    WindowsFeature Net-Framework-45-Core
        {
            Ensure = 'Present'
            Name = 'Net-Framework-45-Core'
        }
cChocoInstaller installChoco

 {

InstallDir = "c:\choco"

 }

    cChocoPackageInstallerset AppDeps
        {
            Name = @("nodejs","git","googlechrome")
            Ensure = 'present'
            DependsOn = '[cChocoInstaller]installChoco'
        }
    }
}