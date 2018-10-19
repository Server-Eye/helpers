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
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        $SensorhubId,
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $props = Get-SeApiContainerProposalList -AuthToken $authtoken -CId $SensorhubId

        foreach ($prop in $props) {
            $sensorhub = Get-SESensorhub -SensorhubId $SensorhubId
        [PSCustomObject]@{
            Name = $prop.Name
            ProposalID = $prop.pid 
            forFree = $prop.forfree
            Beta = $prop.Beta
            Sensorhub = $sensorhub.Name
            "OCC-Connector" = $sensorhub."OCC-Connector"
            Customer = $sensorhub.Customer
        }
        }
    }

    End {

    }
}


