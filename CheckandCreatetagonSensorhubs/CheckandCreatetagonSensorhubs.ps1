<#
    .SYNOPSIS
    Check and Set Tags on Sensorhubs
    
    .DESCRIPTION
    This Script will Set a Tag to a Sensorhub with the same as the Sensorhub. If no Tag is found with the Name of the Sensorhub
    a new Tag will be created.
    The Script will make this for all Customers the user managed.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>

[CmdletBinding()]
Param(
    [Parameter()]
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

try {
    # Check for existing session
    $AuthToken = Test-SEAuth -AuthToken $AuthToken
}
catch {
    # There is no session - prompt for login
    $AuthToken = Connect-SESession
}

if (!$AuthToken) {
    $AuthToken = Connect-SESession
}

if (!$AuthToken) {
    Write-Error "Fehler beim Login!"
    exit 1
}

$SensorhubwithTags = Get-SECustomer -AuthToken $AuthToken| Get-SESensorhub -AuthToken $AuthToken| Get-SEsensorhubtag -AuthToken $AuthToken
$Tags = Get-SETag -AuthToken $AuthToken

foreach ($Sensorhub in $SensorhubwithTags) {

    IF (!($Tags.Name).Contains($Sensorhub.Sensorhub)) {
        Write-Output  "Creating Tag with Name $($Sensorhub.Sensorhub)"
        $NewTag = New-SETag -Name $Sensorhub.Sensorhub -AuthToken $AuthToken
        Write-Output  "Set Tag to Sensorhub $($Sensorhub.Sensorhub)"
        Set-SETag -SensorhubId $Sensorhub.SensorhubId -TagId $NewTag.TagID -AuthToken $AuthToken | Out-Null
    }
    elseif (!($Sensorhub.Tag).Contains($Sensorhub.Sensorhub)) {
        Write-Output  "Set Tag to Sensorhub $($Sensorhub.Sensorhub)"
        Set-SETag -SensorhubId $Sensorhub.SensorhubId -TagId ($Tags | Where-Object { $_.Name -like ($SensorhubwithTags.Sensorhub) }).TagID -AuthToken $AuthToken | Out-Null
    }
    else {
        Write-Output  "All ready set for $($Sensorhub.Sensorhub)"
    }
}