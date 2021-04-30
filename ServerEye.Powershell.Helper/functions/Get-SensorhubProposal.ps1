<#
    .SYNOPSIS
    Get a container's proposals.

    .PARAMETER SensorhubID
    The Sensorhub with this ID will be displayed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-SensorhubProposal {
    Param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        $SensorhubId,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $props = Get-SeApiContainerProposalList -AuthToken $authtoken -CId $SensorhubId
        $CC = Get-CachedContainer -ContainerID $SensorhubId -AuthToken $auth
        $MAC = Get-CachedContainer -AuthToken $auth -ContainerID $cc.parentID
        $customer = Get-CachedCustomer -AuthToken $auth -CustomerId $cc.CustomerId

        foreach ($prop in $props) {
            [PSCustomObject]@{
                Name            = $prop.Name
                ProposalID      = $prop.pid 
                forFree         = $prop.forfree
                Beta            = $prop.Beta
                Sensorhub       = $CC.Name
                "OCC-Connector" = $MAC.Name
                Customer        = $Customer.CompanyName
            }
        }
    }

    End {

    }
}


