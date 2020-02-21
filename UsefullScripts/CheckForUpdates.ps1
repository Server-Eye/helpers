#Requires -Modules ServerEye.PowerShell.Helper
<#
    .SYNOPSIS
    Check for given Update in the Smart Updates Sensor.
    
    .DESCRIPTION
    Check for given Update in the Smart Updates Sensor, is only possible if Sensor is in Error State. 
    
    .PARAMETER KBNumber
    The KB Number of the Update to search for.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    .\CheckForUpdates.ps1 -KBNumber "KB4538674"

    Customer           Sensorhub    Sensor        Update
    --------           ---------    ------        ------
    Server-Eye Support NB-RT-NEW    Smart Updates KB: 4538674 [Windows10.0-KB4538674-x64.cab]

    .LINK 
    https://api.server-eye.de/docs/2/#/agent/list_agent_state
    
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    $KBNumber,
    [Parameter()]
    $AuthToken
)

#Check if Login is there
$authtoken = Test-SEAuth -authtoken $authtoken

#Region internal Variable
#Set Agent Type to PowerShell
$AgentSubTypeSU = "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C" 
#endRegion internal Variable

#Get all Smart Updates Sensors with Error, because only Agents in Error can be search for Updates
$Agents = Get-SECustomer | Get-SESensorhub | Get-SESensor -filter $AgentSubTypeSU | Where-Object { $_.Error -eq $true }

#Check all given Agents for the Update in the RAW Agent Data
foreach ($Agent in $Agents) {
    $state = Get-SeApiAgentStateList -AId $Agent.SensorId -AuthToken $authtoken -IncludeRawData "true" | Where-Object { $_.raw.data.category.list.patchList.name -match $KBNumber }
    if ($state) {
        [PSCustomObject]@{
            Customer  = $Agent.Customer
            Sensorhub = $Agent.Sensorhub
            Sensor    = $Agent.Name
            Update    = $Agent.raw.data.category.list.patchList.name | Select-String -Pattern $KBNumber
        }
    }
}


