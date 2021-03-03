#Requires -Modules ServerEye.PowerShell.Helper
#Requires -Modules importexcel
<# 
    .SYNOPSIS
    Shows all System with no connection.

    .DESCRIPTION
    Shows all System with no connection and the time of the last activity or Systems that were not connected for 14 Days or more.

    Shows time based on the TimeZone of the System on which the Script was executed.

    .PARAMETER LastActiveDays 
    Last Active Days, default is 14

    .PARAMETER PathtoExcelFile 
    Excel File if one should be created

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell
    
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    $LastActiveDays = "14",
    [Parameter(Mandatory = $false)]
    $PathtoExcelFile,
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

#region Server-Eye Default Variables
#endregion Server-Eye Default Variables

#region Internal Variables
$Messageen = "CONNECTED"
$messageen2 = "Connection available"
$messagede = "Verbindung vorhanden"
$result = @()
#endregion Internal Variables

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {
        $tsp = New-TimeSpan -start $container.lastDate -End (Get-Date)
        If ($container.subtype -eq "0" -and $container.message -ne $messageen -and $container.message -ne $messageen2 -and $container.message -ne $messagede) {
            $result += [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                ID            = $container.ID
                "Last Active" = $container.lastDate
                Message       = $container.message
            }
        }
        if ($container.subtype -eq "0" -and $tsp.TotalDays -gt $LastActiveDays) {
            $result += [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                ID            = $container.ID
                "Last Active" = $container.lastDate
                Message       = $container.message
            }
        }     
        If ($container.subtype -eq "2" -and $container.message -ne $messageen -and $container.message -ne $messageen2 -and $container.message -ne $messagede) {
            $occ = $containers | Where-Object { $_.id -eq $container.parentId }
            $result += [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $occ.name
                System        = $container.name
                ID            = $container.ID
                "Last Active" = $container.lastDate
                Message       = $container.message
            } 
        }      
        If ($container.subtype -eq "2" -and $tsp.TotalDays -gt $LastActiveDays) {
            $occ = $containers | Where-Object { $_.id -eq $container.parentId }
            $result += [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $occ.name
                System        = $container.name
                ID            = $container.ID
                "Last Active" = $container.lastDate
                Message       = $container.message
            } 
        }                            
    }
}
if ($PathtoExcelFile) {
    Export-Excel -Path $PathtoExcelFile -InputObject $result -AutoSize -AutoFilter
}
else {
    Write-Output $result
}

