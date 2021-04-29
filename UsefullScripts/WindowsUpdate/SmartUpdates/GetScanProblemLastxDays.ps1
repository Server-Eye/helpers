#Requires -Module ServerEye.PowerShell.helper
<#
    .SYNOPSIS
    Systeme ohne erfogreichen Scan.
    
    .DESCRIPTION
    Liste alle System die keinen Scan in den letzten X Tagen im Smart Updates ausgeführt haben.

    .PARAMETER CustomerId
    ID des Kunden der abgefragt werden soll.

    .PARAMETER LastDays
    ID des Kunden der abgefragt werden soll.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
Param ( 
    [Parameter(Mandatory = $false)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $false)]
    $CustomerId,
    [Parameter(Mandatory = $false)]
    $Lastdays
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$Data = Get-SeApiMyNodesList -AuthToken $AuthToken -ListType object -Filter agent, customer, container

if ($Customerid) {
    $Customers += $Data.Customer
    $Customers = $Data.managedCustomers | Where-Object { $_.ID -eq $CustomerId }
    
}
else {
    $Customers = $Data.managedCustomers
    $Customers += $Data.Customer
}


foreach ($Customer in $Customers) {
    $Containers = $Data.container | Where-Object { $_.customerId -eq $Customer.id -and $_.subtype -eq 2 }  
    foreach ($Container in $Containers) {
        if ($Container.lastdate -gt (Get-date).AddDays(-$Lastdays)) {
            $Agent = $Data.agent | Where-Object { $_.parentId -eq $Container.id -and $_.agenttype -eq "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C" }
            if ($Agent) {
                $state = Get-SeApiAgentStateList -AId $agent.id -Limit 1 -AuthToken $AuthToken -IncludeRawData "true"
                if ($state.state -eq $true -and $state.raw.data.scan.state -ne "OK") {
                    [PSCustomObject]@{
                        Customer          = $customer.name
                        ContainerID       = $Container.id
                        ContainerName     = $Container.name
                        ContainerLastDate = $Container.lastdate
                        ScanState         = $state.raw.data.scan.state
                        lastScan          = $state.raw.data.scan.lastScan
                        lastScanTry       = $state.raw.data.scan.lastScanTry
                    }
                }
            }
        }
    }
}


