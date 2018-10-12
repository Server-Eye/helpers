[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory=$True)]
    [string]$SensorType
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

$AuthToken = Test-SEAuth -AuthToken $AuthToken


$sensors = Get-SECustomer | Get-SESensorhub | Get-SESensor | Where-Object SensorType -eq $SensorType
$hubs = Get-SECustomer | Get-SESensorhub

Compare-Object -ReferenceObject $hubs.Name -DifferenceObject $sensors.Sensorhub | Select-Object -Property @{Name=("Sensorhub without "+ $SensorType); Expression={$_.Inputobject}}