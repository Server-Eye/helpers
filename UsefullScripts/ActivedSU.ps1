Param ( 
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken 
)

#region Module
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
#endregion Module

#region GetCustomerID
$myCustomerList = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

Clear-Host
Write-Host "Wähle den Kunden aus der folgenden Liste aus:" -ForegroundColor Yellow
$i = 1;
if (!$CustomerID) {
    foreach ($customer in $myCustomerList) {
        Write-Host $i ":" $customer.name
        $i += 1
    }
    
    try {
        $customer = $myCustomerList[[int](Read-Host -Prompt 'Gib die Nummer des Kunden ein') - 1]
    }
    catch {
        Write-Host "Ungültige Eingabe!" -ForegroundColor Red
        exit 1
    }
}
#endregion GetCustomerID

#region GetContainerID
$customerSensorhubList = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id | Where-Object subtype -eq 2 
$i = 1;
if (!$containerID) {
    foreach ($Sensorhub in $customerSensorhubList) {
        Write-Host $i ":" $Sensorhub.name
        $i += 1
    }
    try {
        $SEnumberhit = Read-Host -Prompt 'Gib die Nummer des Sensorhubs ein'

        if (!$SEnumberhit) {
            Write-Host "Ungültige Eingabe!" -ForegroundColor Red
            exit 1
        }
        else {
            $Container = ($customerSensorhubList[$SEnumberhit - 1])
        }   
    }
    catch {
        Write-Host "Ungültige Eingabe!" -ForegroundColor Red
        exit 1
    }
}
#endregion GetContainerID

#region CheckSensoronContainer
    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $Container.id
    if ($agents.subtype -like "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C") {
        Write-Host "Smart Updates ist schon aktivert auf dem Sensorhub $(($Container).Name)"
        Exit 1
    }

#endregion CheckSensoronContainer

$urlact = "https://pm.server-eye.de/patch/$($customer.id)/container/$(($Container).id)/enable"

if ($authtoken -is [string]) {
    try {
        Invoke-RestMethod -Uri $urlact -Method Post -Headers @{"x-api-key" = $authtoken }
        Write-Host "Smart Updates wurde aktivert auf dem Sensorhub $(($Container).Name)"
    }
    catch {
        Write-Error "$_"
    }

}
else {
    try {
        Invoke-RestMethod -Uri $urlact -Method Post -WebSession $authtoken
        Write-Host "Smart Updates wurde aktivert auf dem Sensorhub $(($Container).Name)"
    }
    catch {
        Write-Error "$_"
    }
}