#Requires -Module ServerEye.Powershell.Helper

<#
    .SYNOPSIS
        User logoff
 
    .DESCRIPTION
        User logoff
 
    .PARAMETER Username
    Username of the user to be logged off
         
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [string]
    $Build2019,
    [Parameter(Mandatory = $false)]
    [string]
    $Build2016,
    [Parameter(Mandatory = $false)]
    [string]
    $Build2013,
    [Parameter(Mandatory = $false)]
    [string]
    $Build2010,
    [Parameter(Mandatory = $false)]
    [Alias("ApiKey", "Session")]
    [string]
    $AuthToken
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken
$ExchangeAgentType = "A16ADF70-6D42-408f-A103-5F5654C7E807"
$major2019 = "15.2"
$major2016 = "15.1"
$major2013 = "15.0"
$major2010 = "14.3"



$data = Get-SeApiMyNodesList -Filter customer, agent, container -AuthToken $AuthToken -listType object
$customers = $Data.managedCustomers
$customers += $Data.customer
$containers = $data.container
$Connectors = $containers | Where-Object { $_.subtype -eq 0 }
$Sensorhubs = $containers | Where-Object { $_.subtype -eq 2 }
$Agents = $Data.agent

$EXAgent = $Agents | Where-Object { $_.subtype -eq $ExchangeAgentType }
$PatternVersion = "Version \d{1,2}.\d \(Build \d{1,4}\.\d{1,2}\)"
$PatternMajorVersion = "Version \d{1,2}.\d"
$PatternBuild = "\(Build \d{1,4}\.\d{1,2}\)"

foreach ($Agent in $EXAgent) {
    $Version = ($Agent.Message | Select-String $PatternVersion | foreach { $_.matches } | select value).value
    $MajorVersion = ($Version | Select-String $PatternMajorVersion | foreach { $_.matches }) -replace "Version "
    $Build = ($Version | Select-String $PatternBuild | foreach { $_.matches }) -replace "\(Build " -replace "\)"
    $EXVersion = $MajorVersion+"."+$Build
    $Sensorhub = $Sensorhubs | Where-Object {$_.id -eq $Agent.container_id}
    $customer = $customers | Where-Object {$_.id -eq $Agent.customerId}

    switch ($MajorVersion)
    {
        $major2019 {$tocheck = $Build2019}
        $major2016 {$tocheck = $Build2016}
        $major2013 {$tocheck = $Build2013}
        $major2010 {$tocheck = $Build2010}
        Default {
            $tocheck = "older than 2010 SP3"
        }
    }

    [PSCustomObject]@{
        Customer = $customer.name
        Sensorhub = $Sensorhub.name
        SensorhubID = $Sensorhub.id
        Sensor = $agent.name
        SensorID = $agent.ID
        Version = $EXVersion
        Newest = $tocheck
        Upgrade = if ($tocheck -ne $EXVersion) {
            $true
        }else {
            $false
        }
    }
}

