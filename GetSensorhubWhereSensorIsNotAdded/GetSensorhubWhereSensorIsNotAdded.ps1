[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $SensorType
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
}

function cacheSensorTypes ($auth) {
    $Global:SensorTypes = @{}

    $types = Get-SeApiAgentTypeList -AuthToken $auth
    foreach ($type in $types) {
        $Global:SensorTypes.add($type.agentType, $type)
    }

    $avType = New-Object System.Object
    $avType | Add-Member -type NoteProperty -name agentType -value "72AC0BFD-0B0C-450C-92EB-354334B4DAAB"
    $avType | Add-Member -type NoteProperty -name defaultName -value "Managed Antivirus"
    $Global:SensorTypes.add($avType.agentType, $avType)

    $pmType = New-Object System.Object
    $pmType | Add-Member -type NoteProperty -name agentType -value "9537CBB5-9023-4248-AFF3-F1ACCC0CE7A4"
    $pmType | Add-Member -type NoteProperty -name defaultName -value "Patchmanagement"
    $Global:SensorTypes.add($pmType.agentType, $pmType)
}

cacheSensorTypes -auth $AuthToken
if ($Global:SensorTypes.Values | Where-Object {($_.Agenttype -Like $SensorType) -or ($_.DefaultName -like $SensorType )}) {
    $type = $Global:SensorTypes.Values | Where-Object {($_.Agenttype -Like $SensorType) -or ($_.DefaultName -like $SensorType )}
    $sensors = Get-SECustomer | Get-SESensorhub | Get-SESensor | Where-Object SensorType -eq $type.DefaultName
    $hubs = Get-SECustomer | Get-SESensorhub
    Compare-Object -ReferenceObject $hubs.Name -DifferenceObject $sensors.Sensorhub | Select-Object -Property @{Name=("Sensorhub without "+ $Type.DefaultName); Expression={$_.Inputobject}}
    
}else {
    Write-Host "SensorType not in Database!"
}
  







