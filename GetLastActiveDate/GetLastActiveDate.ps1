 <# 
    .SYNOPSIS
    Shows all System with no connection and the time of the last activity.

    .DESCRIPTION
    Shows all System with no connection and the time of the last activity.

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

$culture = [Globalization.cultureinfo]::GetCultureInfo("de-DE")
$format = "yyyy-MM-ddHH:mm:ss"
$messageen = "Connection available"
$messagede = "Verbindung vorhanden"

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
        $lastdate = ($container.lastDate -replace ("[a-zA-Z]", "")).Remove(18)
        $utc = [datetime]::ParseExact($lastdate, $format, $culture)
        $time = Get-LocalTime $utc

        If ($container.subtype -eq "0" -and $container.message -ne $messageen -and $container.message -ne $messagede) {
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $container.name
                System        = "OCC-Connector"
                "Last Active" = $Time
                Message       = $container.message
            }
        }       
        If ($container.subtype -eq "2" -and $container.message -ne $messageen -and $container.message -ne $messagede) {
            $occ = ""
            $occ = Get-SeApiContainer -AuthToken $AuthToken -CId $container.parentId
            [PSCustomObject]@{
                Customer      = $customer.name
                Network       = $occ.name
                System        = $container.name
                "Last Active" = $Time
                Message       = $container.message
            }
        }                                   
    }
}

