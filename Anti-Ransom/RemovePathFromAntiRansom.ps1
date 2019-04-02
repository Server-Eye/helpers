# Julian Recktenwald 19.07.2018
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

$agentId = "A2ED0F41-4419-4A65-828F-92AD8691E297"

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


Clear-Host
Write-Host "  _____                                 ______           " -ForegroundColor Green
Write-Host " / ____|                               |  ____|    "       -ForegroundColor Green
Write-Host "| (___   ___ _ ____   _____ _ __ ______| |__  _   _  ___ " -ForegroundColor Green
Write-Host " \___ \ / _ \ '__\ \ / / _ \ '__|______|  __|| | | |/ _ \" -ForegroundColor Green
Write-Host " ____) |  __/ |   \ V /  __/ |         | |___| |_| |  __/" -ForegroundColor Green
Write-Host "|_____/ \___|_|    \_/ \___|_|         |______\__, |\___|" -ForegroundColor Green
Write-Host "                                               __/ |     " -ForegroundColor Green
Write-Host "AntiRansom Tool - Julian Recktenwald          |___/      " -ForegroundColor Green
Write-Host "julian.recktenwald@kraemer-it.de"
Start-Sleep 2

# Load all customers of the user
$myCustomerList = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

Clear-Host
Write-Host "Wähle den Kunden aus der folgenden Liste aus:" -ForegroundColor Yellow
$i = 1;
foreach ($customer in $myCustomerList) {
    Write-Host $i ":" $customer.name
    $i += 1
}

try {
    $customerId = ($myCustomerList[[int](Read-Host -Prompt 'Gib die Nummer des Kunden ein') - 1]).id
}
catch {
    Write-Host "Ungültige Eingabe!" -ForegroundColor Red
    exit 1
}

# Load all sensorhubs of the selected customer
$customerSensorhubList = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customerId | Where-Object subtype -eq 2 #subtype 2 = sensorhub

Clear-Host
$tagList = New-Object System.Collections.ArrayList
$tagList.Add("Alle Systeme - Nicht nach Tag filtern") | Out-Null

foreach ($sensorhub in $customerSensorhubList) {
    foreach ($tag in $sensorhub.tags) {
        if (!$tagList.Contains($tag.name)) {
            $tagList.Add($tag.name) | Out-Null
        }
    }

}

$i = 0

Write-Host "Gewählter Kunde:" $(Get-SeApiCustomer -AuthToken $AuthToken -CId $customerId).companyName -ForegroundColor Cyan
Write-Host 'Wähle das gewünschte Tag aus der Liste aus:' -ForegroundColor Yellow
foreach ($tag in $tagList) {
    Write-Host $i ":" $tag
    $i += 1
}

$tagInput = Read-Host -Prompt 'Gib die Nummer des Tags ein'
$sensorhubsToUpdate = New-Object System.Collections.ArrayList

$selectedTag = $tagList[$tagInput]
if ($tagInput -ne 0) {
    if (!($selectedTag)) {
        Write-Host "Ungültige Eingabe!" -ForegroundColor Red
        exit 1
    }
    foreach ($sensorhub in $customerSensorhubList) {
        foreach ($tag in $sensorhub.tags) {
            if ($tag.name -eq $selectedTag) {
                $sensorhubsToUpdate.Add($sensorhub) | Out-Null
            }
        }

    }
}
else {
    $sensorhubsToUpdate = $customerSensorhubList
}

$pathsInput = New-Object System.Collections.ArrayList
$repeatInput = $true

Clear-Host
Write-Host "Gewähltes Tag:" $selectedTag "("$sensorhubsToUpdate.Count "Maschinen mit diesem Tag )" -ForegroundColor Cyan
Write-Host 'Gib nun die Pfade zum hinzufügen ein - Lass den Pfad leer und drücke Enter zum fortfahren. z.B: C:\Users\julian.recktenwald\Application Data\*.exe' -ForegroundColor Yellow
do {
    $pathInput = Read-Host -Prompt 'Pfad'
    if ([string]::IsNullOrEmpty($pathInput)) {
        if ($pathsInput.Count -eq 0) {
            Write-Host "Du musst mindestens einen Pfad angeben!" -ForegroundColor Red
        }
        else {
            $repeatInput = $false
        }
    }
    else {
        $pathsInput.Add($pathInput) | Out-Null
    }
} while ($repeatInput -eq $true)

Clear-Host
$count = 0
foreach ($sensorhub in $sensorhubsToUpdate) {
    # Load all AntiRansom agents
    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id | Where-Object subtype -eq $agentId
    foreach ($agent in $agents) {
        # Get the current path settings of the agent
        $currentPaths = (Get-SeApiAgentSettingList -AuthToken $AuthToken -AId $agent.id | Where-Object key -eq "paths").value

        $pathsArray = $currentPaths.Split("|,|")
        foreach ($path in $pathsInput) {

            # Check for existings paths
            if ($pathsArray.contains($path)) {
                #$pathsArray | Get-Member
                $newarray = $pathsArray | Where-Object {$_ -ne $path}
                Write-Host §
                $newClientPaths = $newarray -join "|,|"
                Write-Host $newClientPaths
            }

        }
    
    if ($currentPaths -ne $newClientPaths) {
        $count += 1
        Set-SeApiAgentSetting -AuthToken $AuthToken -AId $agent.id -key "paths" -value $newClientPaths | Out-Null
        Write-Host $sensorhub.name "angepasst." -ForegroundColor Green
        Write-Debug ("New paths: " + $newClientPaths)
    }
    else {
        Write-Host "Überspringe" $sensorhub.name -ForegroundColor DarkYellow
    }
}
}

Write-Host "Einstellugen von" $count "Sensoren angepasst." -ForegroundColor Cyan
Write-Host "Done. Bye!" -ForegroundColor Green