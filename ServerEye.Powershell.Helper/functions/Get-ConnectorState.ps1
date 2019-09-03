 <#
    .SYNOPSIS
    Get the current state of this OCC Connector.
    
    .DESCRIPTION
    Gets the current state of a OCC Connector.
    
    .PARAMETER ConnectorID
    The id of the OCC Connector.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

     .EXAMPLE 
    Get-SEContainerState -ConnectorID "OCC Connector ID"

    Customer      : Wortmann Demo (gesponsert)
    Name          : Management
    ConnectorID   : 03eb26d3-e6eb-498e-b437-6ae810fbd5c5
    StateId       : 26384049
    Date          : 02.09.2019 08:31:44
    LastDate      : 03.09.2019 08:04:05
    Error         : False
    Resolved      : False
    SilencedUntil :

    .LINK 
    https://api.server-eye.de/docs/2/#/container/list_container_state
#>

function Get-ConnectorState {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $ConnectorID,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        Get-SEContainerState -ContainerID $ConnectorID -AuthToken $AuthToken    
    }
    End{

    }
}