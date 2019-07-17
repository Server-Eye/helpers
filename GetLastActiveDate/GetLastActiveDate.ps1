
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
$culture = [Globalization.cultureinfo]::GetCultureInfo("de-DE")
$format = "yyyy-MM-ddHH:mm:ss"
$messageen = "Connection available"
$messagede = "Verbindung vorhanden"
$shutdownde = "Dienst oder Server wurde heruntergefahren."
$shutdownen = ""
$now = Get-Date

$AuthToken = Test-SEAuth -AuthToken $AuthToken
Function Get-LocalTime($UTC)
{
$strCurrentTimeZone = (Get-TimeZone).id
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTC, $TZ)
Return $LocalTime
}

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {
        $date = ($container.lastDate -replace ("[a-zA-Z]", "")).Remove(18)
        $utc = [datetime]::ParseExact($date, $format, $culture)
        $time = Get-LocalTime $utc
        $tsp = New-TimeSpan -start $time -End $now

        Write-Debug $container


        If ($container.subtype -eq "0" -and $container.message -ne $messageen -and $container.message -ne $messagede -and $container.message -ne $shutdownde) {
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            }
        }
        if ($container.subtype -eq "0" -and $tsp.TotalDays -gt $LastActiveDays -and $container.message -ne $shutdownde){
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                "Last Active" = $time
                Message       = "Last Message: " + $container.message
            }
        }     
        If ($container.subtype -eq "2" -and $container.message -ne $messageen -and $container.message -ne $messagede -and $container.message -ne $shutdownde) {
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
        If ($container.subtype -eq "2" -and $tsp.TotalDays -gt $LastActiveDays  -and $container.message -ne $shutdownde) {
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

