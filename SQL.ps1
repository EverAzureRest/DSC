Configuration AppSQL
{
import-dscresource -ModuleName xSQLServer
$setupcred = get-automationpscredential -Name SQLSetupAcct
$instancename = "MSSQLSERVER"
$DBSvcAcct = get-automationpscredential -Name SQLSvcAcct
$sacred = get-automationpscredential -Name SAAcct
$sasecurepwd = $sacred.Password
$sapwd = $sacred.GetNetworkCredential().Password

Node DBE
{

InstanceName = $instancename
SetupCredential = $setupcred
InstallSharedDir = "C:\Program Files\Microsoft SQL Server\"
InstanceDir = "C:\Program Files\Microsoft SQL Server\$($intancename)\"
InstallSQLDataDir = "E:\Databases\"
SourcePath = "\\Path\to\Network\Share\SQLinstaller.msi"
SecurityMode = "Mixed"
SQLSvcAccount = $DBSvcAcct
SQLTempDBDir = "F:\DBTEMP\"
SQLTempDBLogDir = "G:\DBTEMPLOGS\"
UpdateEnabled = $true
SAPWD = $sapwd

}

Node RS
{
InstanceName = $instancename
RSSQLInstanceName = "ReportingServices"
SetupCredential = $setupcred
InstallSharedDir = "C:\Program Files\Microsoft SQL Server\"
InstanceDir = "C:\Program Files\Microsoft SQL Server\$($intancename)\"
InstallSQLDataDir = "E:\Databases\"
SourcePath = "\\Path\to\Network\Share\SQLinstaller.msi"
SecurityMode = "Mixed"
SQLSvcAccount = $DBSvcAcct
Features = "Reporting Sevices"

}




}