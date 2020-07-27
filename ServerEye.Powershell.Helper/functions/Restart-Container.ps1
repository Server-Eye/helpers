<#
    .SYNOPSIS
    Restarts a container. 

    .PARAMETER cId
    The id of the container.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Restart-SEContainer -containerid "f62c53ad-9bc0-4060-8f4a-35030164db5d"

    Customer      : Wortmann Demo (gesponsert)
    OCC-Connector : Management
    Name          : DC02
    SensorhubId   : f62c53ad-9bc0-4060-8f4a-35030164db5d
    Restart       : Success
    ErrorMessage  :

    .EXAMPLE
    Restart-OCCConnector -containerid "03eb26d3-e6eb-498e-b437-6ae810fbd5c5"

    Customer     : Wortmann Demo (gesponsert)
    Name         : Management
    ConnectorID  : 03eb26d3-e6eb-498e-b437-6ae810fbd5c5
    MachineName  : SE-HV01
    Restart      : Success
    ErrorMessage :
    
#>
function Restart-Container {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the container.")]
        [Alias("ConnectorID", "SensorhubId")]
        [ValidateNotNullOrEmpty()]
        [string]
        $containerid,
        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $container = Get-SEContainer -containerid $containerid -AuthToken $AuthToken
        if ($container."OCC-Connector") {
            RestartSensorhub -container $container -AuthToken $AuthToken
        }
        else {
            RestartOCCConnector -container $container -AuthToken $AuthToken
        }
    }
    End {

    }

}

function RestartSensorhub($container, $AuthToken) {
    try {
        Restart-SeApiContainer -CId $container.SensorhubId -AuthToken $AuthToken
        [PSCustomObject]@{
            Customer        = $container.Customer
            "OCC-Connector" = $container."OCC-Connector"
            Name            = $container.name
            SensorhubId     = $container.SensorhubId
            Restart         = "Success"
            ErrorMessage    = ""  
        }
    }
    catch {
        [PSCustomObject]@{
            Customer        = $container.Customer
            "OCC-Connector" = $container."OCC-Connector"
            Name            = $container.name
            SensorhubId     = $container.SensorhubId
            Restart         = "Failed"
            ErrorMessage    = $_

        }
    }
}

function RestartOCCConnector($container, $AuthToken) {
    try {
        Restart-SeApiContainer -CId $container.ConnectorID -AuthToken $AuthToken
        [PSCustomObject]@{
            Customer     = $container.Customer
            Name         = $container.name
            ConnectorID  = $container.ConnectorID
            MachineName  = $container.MachineName
            Restart      = "Success"
            ErrorMessage = ""  
        }
    }
    catch {
        [PSCustomObject]@{
            Customer     = $container.Customer
            Name         = $container.name
            ConnectorID  = $container.ConnectorID
            MachineName  = $container.MachineName
            Restart      = "Failed"
            ErrorMessage = $_

        }
    }
}

