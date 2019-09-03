 <#
    .SYNOPSIS
    Get the current state of this Sensorhub.
    
    .DESCRIPTION
    Gets the current state of a Sensorhub.
    
    .PARAMETER containerid
    The id of the container.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SEContainerState -SensorhubId "Senorhub ID"

    Customer      : Wortmann Demo (gesponsert)
    Name          : DASISRV
    Connector     : Management
    SensorhubID   : 786fc0c1-f83f-4245-9311-f85d7550d828
    StateId       : 26267775
    Date          : 27.08.2019 19:58:06
    LastDate      : 03.09.2019 08:06:45
    Error         : False
    Resolved      : False
    SilencedUntil :

    .LINK 
    https://api.server-eye.de/docs/2/#/container/list_container_state
#>

function Get-SensorhubState {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorhubId,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        Get-SEContainerState -ContainerID $SensorhubId -AuthToken $AuthToken    
    }
    End{

    }
}