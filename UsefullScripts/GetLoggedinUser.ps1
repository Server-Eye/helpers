<#
    .SYNOPSIS
    Shows all logged in User.
    
    .DESCRIPTION
    Shows all logged in User or the last Sensorhub where es user was logged in for a given or all Customers.
    
    .PARAMETER CustomerID
    Id of the Customer that should be checked

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>

[CmdletBinding(DefaultParameterSetName = "")]
Param(
    [parameter(Mandatory = $false,
        Position = 0,
        HelpMessage = "Id of the Customer that should be checked")]
    [ValidateNotNullOrEmpty()]
    [string]
    $CustomerID,

    [parameter(Mandatory = $false,
        HelpMessage = "Id of the Customer that should be checked")]
    [ValidateNotNullOrEmpty()]
    [switch]
    $Client,

    [parameter(Mandatory = $false,
        HelpMessage = "Id of the Customer that should be checked")]
    [ValidateNotNullOrEmpty()]
    [switch]
    $Terminalserver,

    [Parameter(Mandatory = $false,
        HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
    $AuthToken
)

if ($Client.IsPresent -eq $true) {
    $type = "A9D8173C-9A40-406a-B7DB-538231F4E3A2"
}
elseif ($Terminalserver.IsPresent -eq $true) {
    $type = "993DB9BD-27A1-4082-85C4-815C126741A2"
}

$authtoken = Test-SEAuth -AuthToken $authtoken

$data = Get-SeApiMyNodesList -Filter customer, agent, container -AuthToken $AuthToken -listType object
$containers = $data.container
$Sensorhubs = $containers | Where-Object { $_.subtype -eq 2 }

$result = @()

if ($CustomerID) {
    $customers = $Data.managedCustomers | Where-Object { $_.id -eq $CustomerID }
    $customers += $data.customer  | Where-Object { $_.id -eq $CustomerID }
}
else {
    $customers = $Data.managedCustomers
    $customers += $data.customer
}

foreach ($customer in $customers) {
    $Agents = $Data.agent | Where-Object { $_.agentType -eq $type -and $_.customerId -eq $customer.id }


    foreach ($Agent in $Agents) {

        $state = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $agent.id -Limit 1 -IncludeRawData "true"

        $Sensorhub = $Sensorhubs | Where-Object { $_.id -eq $agent.parentId }
        
        [PSCustomObject]@{ 
            Customer       = $Customer.Name
            Sensorhub      = $Sensorhub.name
            user           = if ($Client) { $state.raw.data.sysInfo.lastlogonuser }elseif ($Terminalserver) {
                $state.raw.data.sessInfo.user
            }
            lastLogon      = if ($Client) { $state.raw.data.sysInfo.lastLogonUserTime }elseif ($Terminalserver) {
                $state.raw.data.sessInfo.login
            }
            LastConnection = $Sensorhub.lastDate
        }
    }
}
