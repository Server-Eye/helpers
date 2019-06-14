<# 
    .SYNOPSIS
    This script will check the 2 Faktor Authentication for all Users.

    .DESCRIPTION
    This script will check the 2 Faktor Authentication for all Users.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
    
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

$authtoken = Test-SEAuth -authtoken $authtoken

$users = Get-SEUser | Where-Object IsGroup -eq $false

$activ = "502"
$deactiv = "503"

$culture = [Globalization.cultureinfo]::GetCultureInfo("de-DE")
$format = "yyyy-MM-ddHH:mm:ss"

Function Get-LocalTime($UTC)
{
$strCurrentTimeZone = (Get-TimeZone).id
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTC, $TZ)
Return $LocalTime
}



foreach ($user in $users){
    $2faactive = Get-SeApiActionlogList -Of $user.UserID -AuthToken $authtoken -IncludeRawData $true | Where-Object {($_.change.type -eq $activ)} | Select-Object -First 1
    $2fadeactive = Get-SeApiActionlogList -Of $user.UserID -AuthToken $authtoken -IncludeRawData $true | Where-Object {($_.change.type -eq $deactiv)} | Select-Object -First 1
    if (!$2faactive) {
        [PSCustomObject]@{
            UserName = $user.Username
            Email = $user.EMail
            Customer = $user.Company
            "Status 2FA" = "Niemals aktivert"
        }

    }elseif ($2fadeactive) {
    $dateactive = ($2faactive.changeDate -replace ("[a-zA-Z]", "")).Remove(18)
    $utcactive = [datetime]::ParseExact($dateactive, $format, $culture)
    $timeactive = Get-LocalTime $utcactive

    $datedeactive = ($2fadeactive.changeDate -replace ("[a-zA-Z]", "")).Remove(18)
    $utcdeactive = [datetime]::ParseExact($datedeactive, $format, $culture)
    $timedeactive = Get-LocalTime $utcdeactive

    $tsp = New-TimeSpan -start $timedeactive -End $timeactive
    if ($tsp -lt 0) {
        [PSCustomObject]@{
            UserName = $user.Username
            Email = $user.EMail
            Customer = $user.Company
            "Status 2FA" = ("Deaktiverit am "+ $timedeactive.tostring())
        }
    }if ($tsp -gt 0) {
        [PSCustomObject]@{
            UserName = $user.Username
            Email = $user.EMail
            Customer = $user.Company
            "Status 2FA" = ("Aktiverit am " + $timeactive.tostring())
        }
    }
    }

}
