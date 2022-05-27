#Requires -Module ServerEye.Powershell.Helper

<#
    .SYNOPSIS
        Sets Service to ignore List
        
    .DESCRIPTION
        Sets Service to ignore List

    .PARAMETER customerId 
    ID of the Customer

    .PARAMETER PathToIgnoreCSV 
    Path to the CSV with a List of the Services, please use Services as the heading in the CSV.

    .NOTES
        Author  : Server-Eye
        Version : 1.0

    .Link
    https://support.microsoft.com/de-de/topic/9-m%C3%A4rz-2021-kb5000802-betriebssystembuilds-19041-867-und-19042-867-63552d64-fe44-4132-8813-ef56d3626e14
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    $customerId,
    [Parameter(Mandatory = $false)]
    $PathToIgnoreCSV,
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$AgentType = "43C5B1C4-EF06-4117-B84A-7057EA3B31CF"

$data = Get-SeApiMyNodesList -Filter customer, agent, container -AuthToken $AuthToken -listType object

$containers = $data.container




if ($customerId) {
    $customers = $Data.managedCustomers | Where-Object { $_.id -eq $customerId }
}
else {
    $customers = $Data.managedCustomers
}


# Load all sensorhubs of the selected customer
$customerSensorhubList = $containers | Where-Object { $_.subtype -eq 2 -and $customers.id -contains $_.customerid }

Clear-Host
$tagList = [PSCustomObject]@{
    id       = 0
    name     = "Alle Systeme - Nicht nach Tag filtern"
    readonly = $false
}

foreach ($sensorhub in $customerSensorhubList) {
    foreach ($tag in $sensorhub.tags) {
        if ($tagList.Name -notcontains $tag.name) {
            $tagList = [Array]$tagList + $tag
        }
    }
}



if ($customers.count -ge 1) {
    Write-Host "Gewählter Kunden:" ($customers.name -join ", ") -ForegroundColor Cyan
}
else {
    Write-Host "Gewählter Kunde:" $customers.name -ForegroundColor Cyan
}

$i = 0
Write-Host 'Wähle das gewünschte Tag aus der Liste aus wo die Ausnahme gesetzt werden soll:' -ForegroundColor Yellow
foreach ($tag in $tagList) {
    Write-Host $i ":" $tag.Name
    $i += 1
}
$AddtagInput = Read-Host -Prompt 'Gib die Nummer des Tags ein'

$selectedAddTag = $tagList[$AddtagInput]
if (!$selectedAddTag) {
    Write-Error "Ungültige Eingabe!"
    exit 1
}
elseif ($selectedAddTag.id -eq 0) {
    $sensorhubsToUpdate = $customerSensorhubList
}
else {
    $i = 0
    Write-Host 'Wähle das gewünschte Tag aus der Liste aus wo die Ausnahme nicht gesetzt werden soll:' -ForegroundColor Yellow
    foreach ($tag in $tagList) {
        Write-Host $i ":" $tag.Name
        $i += 1
    }
    $RemovetagInput = Read-Host -Prompt 'Gib die Nummer des Tags ein'
    $selectedRemoveTag = $tagList[$RemovetagInput]
    if (!($selectedRemoveTag)) {
        Write-Error "Ungültige Eingabe!"
        exit 1
    }
    elseif ($selectedRemoveTag -eq 0) {
        $sensorhubsToUpdate = $customerSensorhubList | Where-Object { $_.tags.Id -contains $selectedAddTag.id }
    }
    else {
        $sensorhubsToUpdate = $customerSensorhubList | Where-Object { $_.tags.Id -contains $selectedAddTag.id -and $_.tags.Id -notcontains $selectedRemoveTag.id }
    }
}

if (!$sensorhubsToUpdate) {
    Write-Host "$($sensorhubsToUpdate.Count) Maschinen mit deiner Tag kombination." -ForegroundColor Cyan
    exit
}
else {
    $Agents = $Data.agent | Where-Object { $_.subtype -eq $AgentType -and $sensorhubsToUpdate.id -contains $_.parentId }
    Clear-Host
    if ($agents.count -eq 0) {
        Write-Host "$($sensorhubsToUpdate.Count) Maschinen mit deiner Tag kombination, davon haben $($agents.count) den Windows Dienste Gesundheit Sensor angelegt, müssen keine veränderungen gemacht werden." -ForegroundColor Cyan
        exit
    }
    else {
        Write-Host "$($sensorhubsToUpdate.Count) Maschinen mit deiner Tag kombination, davon haben $($agents.count) den Windows Dienste Gesundheit Sensor angelegt" -ForegroundColor Cyan
        Write-Host 'Gib nun die Dienste (Dienstname, nicht Anzeigename) zum hinzufügen ein - Lass den Dienst leer und drücke Enter zum fortfahren. z.B: CCService' -ForegroundColor Yellow
        if ($PathToIgnoreCSV) {
            $pathsInput = (Import-csv -Path $PathToIgnoreCSV).Services
        }
        else {
            $pathsInput = New-Object System.Collections.ArrayList
            $repeatInput = $true
        }
        do {
            $pathInput = Read-Host -Prompt 'Dienst'
            if ([string]::IsNullOrEmpty($pathInput)) {
                if ($pathsInput.Count -eq 0) {
                    Write-Host "Du musst mindestens einen Dienst angeben!" -ForegroundColor Red
                }
                else {
                    $repeatInput = $false
                }
            }
            else {
                $pathsInput.Add($pathInput) | Out-Null
            }
        } while ($repeatInput -eq $true) 
    }
}


Clear-Host
$count = 0
foreach ($sensorhub in $sensorhubsToUpdate) {
    # Load all AntiRansom agents
    $Agents = $Data.agent | Where-Object { $_.Type -eq 3 -and $_.parentId -eq $sensorhub.id -and $_.subtype -eq $AgentType }
    foreach ($agent in $agents) {
        # Get the current path settings of the agent
        $currentPaths = (Get-SeApiAgentSettingList -AuthToken $AuthToken -AId $agent.id | Where-Object key -eq "serviceList").value

        $newClientPaths = $currentPaths

        if ([string]::IsNullOrEmpty($currentPaths)) {
            $newClientPaths = [string]::Join('|,|', $pathsInput)
        }
        else {

            $pathsArray = $currentPaths.Split("|,|")
            foreach ($path in $pathsInput) {
                # Check for existings paths
                if (!$pathsArray.contains($path)) {
                    $newClientPaths = $newClientPaths + "|,|" + $path
                    Write-Debug ("Added " + $path)
                }
                else {
                    Write-Debug ("Skip " + $path)
                }
            }
        }

        if ($currentPaths -ne $newClientPaths) {
            $count += 1
            Set-SeApiAgentSetting -AuthToken $AuthToken -AId $agent.id -key "serviceList" -value $newClientPaths | Out-Null
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