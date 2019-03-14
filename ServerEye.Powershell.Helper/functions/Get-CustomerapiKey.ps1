
<#
    .SYNOPSIS
    Get a list of all API-Keys.

    .DESCRIPTION
    Get a list of all API-Keys.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomerapiKey

    apiKey       : ************************************
    Name         : TESTKEY Target Id 2
    targetType   : 1
    targetId     : d3d24078-5f0b-429b-80d1-fb992f47c3c3
    targetName   : Andyvision
    customerId   : d3d24078-5f0b-429b-80d1-fb992f47c3c3
    CustomerName : Andyvision
    validUntil   :
    maxUses      : 0
    used         : 0
    createdOn    : 11.09.2018 09:30:20

    .LINK 
    https://api.server-eye.de/docs/2/

#>
function Get-CustomerapiKey {
    [CmdletBinding()]
    Param(
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $apiKeys = Get-SeApiCustomerApikeyList -AuthToken $AuthToken
            
        foreach ($apiKey in $apiKeys) {
            [PSCustomObject]@{
                apiKey       = $apiKey.apiKey
                Name         = $apiKey.name
                targetType   = $apiKey.targetType
                targetId     = $apiKey.targetId
                targetName   = $apiKey.targetName
                customerId   = $apiKey.customerId
                CustomerName = $apiKey.customerName
                validUntil   = $apiKey.validUntil
                maxUses      = $apiKey.maxUses
                used         = $apiKey.used
                createdOn    = $apiKey.createdOn
            }
        }
    }
}