param(
        [Parameter(Mandatory)]
        [String]$domainFQDN
)
$Params = @{"domain"=$domainFQDN}
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $True
        },
        @{
            NodeName = "PDCE"
            PSDscAllowDomainUser = $True
        }
    )
}

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName "eus2services" -AutomationAccountName "labsubautomation" -ConfigurationName "Domain" -ConfigurationData $ConfigData -Parameters $Params