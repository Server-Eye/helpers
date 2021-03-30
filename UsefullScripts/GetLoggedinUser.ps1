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

    [Parameter(Mandatory = $false,
        HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
    $AuthToken
)

$type = "A9D8173C-9A40-406a-B7DB-538231F4E3A2"

$authtoken = Test-SEAuth -AuthToken $authtoken

$Data = Get-SeApiMyNodesList -Filter Agent, Customer, container -AuthToken $AuthToken
$Sensorhubs = $Data | Where-Object { $_.Type -eq 2 -and $_.subtype -eq 2}
$result = @()
if ($CustomerID) {
    $customers = $Data | Where-Object { $_.Type -eq 1 -and $_.id -eq $CustomerID } | Sort-Object -Property Name
}
else {
    $customers = $Data | Where-Object { $_.Type -eq 1 } | Sort-Object -Property Name
}

foreach ($customer in $customers) {
    $PCAgents = $Data | Where-Object { $_.Type -eq 3 -and $_.agentType -eq $type -and $_.customerId -eq $customer.id }

    foreach ($pcagent in $PCAgents) {

        $state = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $pcagent.id -Limit 1 -IncludeRawData "true"

        $Sensorhub = $Sensorhubs | Where-Object { $_.id -eq $pcagent.parentId }
        
        [PSCustomObject]@{ 
            Customer   = $Customer.Name
            Sensorhub  = $Sensorhub.name
            user       = $state.raw.data.sysInfo.lastlogonuser
            lastLogon  = $state.raw.data.sysInfo.lastLogonUserTime
            LastConnection = $Sensorhub.lastDate
        }
    }
}
