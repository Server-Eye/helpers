<# 
    .SYNOPSIS
    Shows all Sensors with Creation date.

    .DESCRIPTION
    Shows all Sensors with Creation date.

    .PARAMETER CustomerID
    The Customer from where the Sensors should be shown

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
    
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    $CustomerID,
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

$authtoken = Test-SEAuth -authtoken $authtoken

$Sensors = Get-SESensorhub -CustomerId $CustomerID | Get-SESensor 


$culture = [Globalization.cultureinfo]::GetCultureInfo("de-DE")
$format = "yyyy-MM-ddHH:mm:ss"

Function Get-LocalTime($UTC) {
    $strCurrentTimeZone = (Get-TimeZone).id
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    $LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTC, $TZ)
    Return $LocalTime
}




foreach ($sensor in $sensors) {
    If($sensor.sensortype -eq $null){
        continue
    }else {
        $create = Get-SeApiActionlogList -Of $Sensor.Sensorid -AuthToken $authtoken -IncludeRawData $true -type 2
        $datecreating = (($create.changedate -replace ("[a-zA-Z]", "")).Remove(18))
        $utccreating = [datetime]::ParseExact($datecreating, $format, $culture) 
        $timecreating = Get-LocalTime $utccreating
        [PSCustomObject]@{
            Sensorname      = $sensor.Name
            SensorId        = $sensor.SensorId
            Created         = $timecreating.tostring()
            "Created By"    = $create.User.Email
            Sensorhub       = $sensor.Sensorhub
            'OCC-Connector' = $sensor.'OCC-Connector'
        }
    }
}
        

