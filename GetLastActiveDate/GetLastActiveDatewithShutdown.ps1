
 <# 
    .SYNOPSIS
    Shows all System with no connection.

    .DESCRIPTION
    Shows all System with no connection and the time of the last activity or Systems that were not connected for 14 Days or more.

    Shows time based on the TimeZone of the System on which the Script was executed.

    .PARAMETER Apikey 
    Agent intervall from the OCC.
    
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)


# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}


$LastActiveDays = "14"
$messageen = "Connection available"
$messagede = "Verbindung vorhanden"
$shutdownde = "Dienst oder Server wurde heruntergefahren."
$shutdownen = ""
$now = Get-Date

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {
        $time = Convert-SEDBTime -date $container.lastDate
        $tsp = New-TimeSpan -start $time -End $now

        Write-Debug $container


        If ($container.subtype -eq "0" -and $container.message -ne $messageen -and $container.message -ne $messagede) {
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            }
        }
        if ($container.subtype -eq "0" -and $tsp.TotalDays -gt $LastActiveDays){
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            }
        }     
        If ($container.subtype -eq "2" -and $container.message -ne $messageen -and $container.message -ne $messagede) {
            $occ = ""
            $occ = Get-SeApiContainer -AuthToken $AuthToken -CId $container.parentId
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $occ.name
                System        = $container.name
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            } 
        }      
        If ($container.subtype -eq "2" -and $tsp.TotalDays -gt $LastActiveDays) {
            $occ = ""
            $occ = Get-SeApiContainer -AuthToken $AuthToken -CId $container.parentId
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $occ.name
                System        = $container.name
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            } 
        }                            
    }
}

