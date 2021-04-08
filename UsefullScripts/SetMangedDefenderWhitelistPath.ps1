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
try {
    $authtoken = test-seauth $authtoken
}
catch {
    Exit
}


#Get the Content of the Whitelist File
$set = get-content $path
#endRegion read external Variable

#Region MainFuction
#Alle Defender Sensoren suchen
$data = Get-SeApiMyNodesList -Filter agent -AuthToken $AuthToken -listType object
$Agents = $Data.agent | Where-Object {$_.subType -eq $sensortype}

#endRegion MainFuction

# Daten aus $path ergänzt durch | 
$sensorinput = [string]::Join('|,|', $set)
foreach ($defender in $Agents) { 
    Set-SESensorSetting -Key $einstellung -SensorId $defender.id -Value $sensorinput -AuthToken $AuthToken
}