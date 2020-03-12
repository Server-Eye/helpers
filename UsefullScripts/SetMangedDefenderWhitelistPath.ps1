 <#
    .SYNOPSIS
    Set the given pathes to the Sensor.
    
    .DESCRIPTION
    Outputs a list of all Agentypes in Server-Eye.

    .PARAMETER path
    Path to the file with the Pathes to whitelist
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .LINK 
    https://api.server-eye.de/docs/2/

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    $path,
    [Parameter(Mandatory = $false)]
    $AuthToken
)

#Region internal Variable
#SensorSettings Key
$einstellung = "whitelistedFiles"

#Set Type to Managed Windows Defender
$sensortype = "0000CBF2-63AA-4911-B26D-924C9FC7ABA6" 
#endRegion internal Variable

#Region read external Variable
#Check if Login is there
$authtoken = test-seauth $authtoken

#Get the Content of the Whitelist File
$set = get-content $path
#endRegion read external Variable

#Region MainFuction
#Alle Defender Sensoren suchen
$defenders = Get-SECustomer | Get-SESensorhub | Get-SESensor -filter $sensortype
#endRegion MainFuction

# Daten aus $path ergänzt durch | 
$sensorinput = [string]::Join('|,|', $set)
foreach ($defender in $defenders) { 
    Set-SESensorSetting -Key $einstellung -SensorId $defender.sensorid -Value $sensorinput
}