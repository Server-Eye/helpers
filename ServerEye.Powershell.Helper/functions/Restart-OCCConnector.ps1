<#
    .SYNOPSIS
    Restarts a occ connector. 

    .PARAMETER ConnectorId
    The id of the occ connector

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Restart-OCCConnector -ConnectorId "03eb26d3-e6eb-498e-b437-6ae810fbd5c5"

    Customer     : Wortmann Demo (gesponsert)
    Name         : Management
    ConnectorID  : 03eb26d3-e6eb-498e-b437-6ae810fbd5c5
    MachineName  : SE-HV01
    Restart      : Success
    ErrorMessage :
#>
function Restart-OCCConnector {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the OCC-Connector.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ConnectorId,
        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        Restart-Container -AuthToken $AuthToken -containerid $ConnectorId
    }

    End {

    }

}

