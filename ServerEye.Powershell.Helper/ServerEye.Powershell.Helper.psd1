@{
RootModule = 'ServerEye.Powershell.Helper.psm1'
ModuleVersion = '1.0'
GUID = 'cb03da1f-dd3e-4fa5-812d-1cc9fa5c1180'
Author = 'Server-Eye'
CompanyName = 'Kraemer IT Solutions GmbH'
Copyright = '(c) Kraemer IT Solutions GmbH. All rights reserved.'
Description = 'Helper to access the Server-Eye API'
PowerShellVersion = '3.0'
DotNetFrameworkVersion = '4.0'
CLRVersion = '4.0'
AliasesToExport = @()
CmdletsToExport = @()
FunctionsToExport = @('Connect-ServerEyeSession', 'Disconnect-ServerEyeSession', 'Get-VisibleCustomers',
                  'Get-ContainerForCustomer', 'Get-AgentsForContainer', 'Get-NotificationForAgent',
                  'Get-UsageForCustomer', 'Get-AllVisibleAgents')
}
