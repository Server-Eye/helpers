
<#
    .SYNOPSIS
    Get a list of all API-Keys.

    .DESCRIPTION
    Get a list of all API-Keys.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-CustomerapiKey {
    [CmdletBinding()]
    Param(
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
            $apiKeys = Get-SeApiCustomerApikeyList -AuthToken $AuthToken
            
            foreach ($apiKey in $apiKeys){
                    [PSCustomObject]@{
                        apiKey = $apiKey.apiKey
                        Name = $apiKey.name
                        targetType = $apiKey.targetType
                        targetId = $apiKey.targetId
                        targetName = $apiKey.targetName
                        customerId = $apiKey.customerId
                        CustomerName = $apiKey.customerName
                        validUntil = $apiKey.validUntil
                        maxUses = $apiKey.maxUses
                        used = $apiKey.used
                        createdOn = $apiKey.createdOn
                    }
            }
    }
}