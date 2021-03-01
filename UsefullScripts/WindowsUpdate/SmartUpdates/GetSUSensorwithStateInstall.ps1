#Requires -Module ServerEye.PowerShell.helper
 <#
    .SYNOPSIS
    Liste alle System die eine Installation im Smart Updates anstehen haben.
    
    .DESCRIPTION
    Liste alle System die eine Installation im Smart Updates anstehen haben.

    .PARAMETER CustomerId
    ID des Kunden der abgefragt werden soll.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
Param ( 
    [Parameter(Mandatory = $false)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $false)]
    $CustomerId
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$Date = Get-SeApiMyNodesList -AuthToken $apikey -ListType object -Filter agent,customer

if ($Customerid) {
    $Customers = $date.managedCustomers | Where-Object {$_.ID -eq $CustomerId}
}else {
    $Customers = $date.managedCustomers
}


foreach ($Customer in $Customers){
    $Containers = $Date.container | Where-Object {$_.customerId -eq $Customer.id} 
    $Agents = $Date.agent | Where-Object {$_.customerId -eq $Customer.id -and $_.agenttype -eq "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C"} 

    foreach ($Agent in $Agents) {
        $state = Get-SeApiAgentStateList -AId $agent.id -Limit 1 -AuthToken $apikey -IncludeRawData "true"
        $Container = $Containers | Where-Object {$_.Id -eq $Agent.container_id}
        if ($state.raw.data.shutdownAction.installReady -eq $true) {
            [PSCustomObject]@{
                Customer = $customer.name
                ContainerID = $Container.id
                ContainerName = $Container.name
            }
        }

    }


}