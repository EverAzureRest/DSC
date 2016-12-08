$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $True
        },
                @{
            NodeName = "DBE"
            PSDscAllowDomainUser = $true
        }
    )
}

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName "eus2services" -AutomationAccountName "labsubautomation" -ConfigurationName "SQL" -ConfigurationData $ConfigData