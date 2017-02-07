Configuration daRDGW
{

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName PowerShellModule

Node RDGWServer {
    WindowsFeature ADDomainServices {
        Ensure = 'Present'
        Name = 'AD-Domain-Services'
        }
    WindowsFeature NetworkPolicyServices {
        Ensure = 'Present'
        Name = 'NPAS'
        }
    WindowsFeature RPCOverHTTPProxy {
        Ensure = 'Present'
        Name = 'RPC-over-HTTP-Proxy'
        }
    PSModuleResource RDGWModule {
        Ensure = 'Present'
        Module_Name = 'RdsGw'
        }
}

Node MFAServer {
    WindowsFeature IIS {
        Ensure = 'Present'
        Name = 'Web-Server'
        }
    WindowsFeature IISASPNET {
        Ensure = 'Present'
        Name = 'Web-Asp-Net45'
        }
    WindowsFeature WebBasicAuth {
        Ensure = 'Present'
        Name = 'Web-Basic-Auth'
        }
    WindowsFeature IIS6MgmtCompat {
        Ensure = 'Present'
        Name = 'Web-Mgmt-Compat'
        }
    }

}