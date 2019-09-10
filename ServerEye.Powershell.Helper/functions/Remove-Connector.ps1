<#
    .SYNOPSIS
    Deletes a Connector, all of its historical data and all its agents.

    .PARAMETER ConnectorID
    The id of the Connector.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .EXAMPLE 
    Remove-Connector -ConnectorId "ConnectorID"

     .LINK 
    https://api.server-eye.de/docs/2/#/container/del_container
    

#>

function Remove-Connector {
    [CmdletBinding(DefaultParameterSetName ="")]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory = $true)]
        $ConnectorId,
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        Remove-SEContainer -ContainerID $ConnectorId  -AuthToken $AuthToken
    }

    End {

    }
}

