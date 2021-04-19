<#
    .SYNOPSIS
    Restarts a Sensor. 

    .PARAMETER SensorId
    The id of the Sensor.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Restart-SESensor -Sensorid "12ac64d4-cc35-4919-9ad5-7ac4fe390423"

    Customer      : Wortmann Demo (gesponsert)
    OCC-Connector : servereye.demo
    Sensorhub     : APPSRV
    SensorName    : HDD C
    SensorID      : 12ac64d4-cc35-4919-9ad5-7ac4fe390423
    Restart       : Success
    ErrorMessage  : 


    
#>
function Restart-Sensor {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the Sensor.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SensorId,
        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $Sensor = Get-SeApiAgent -AId $sensorid -AuthToken $AuthToken
        $container = Get-SEContainer -containerid $sensor.parentId -AuthToken $AuthToken
        RestartSensor -Sensor $Sensor -AuthToken $AuthToken -container $container
    }
    End {

    }

}

function RestartSensor($Sensor, $AuthToken, $container) {
    try {
        Restart-SeApiAgent -aid $sensor.aid -AuthToken $AuthToken
        [PSCustomObject]@{
            Customer        = $container.Customer
            "OCC-Connector" = $container."OCC-Connector"
            Sensorhub       = $container.Name
            SensorName      = $Sensor.name
            SensorID        = $Sensor.aId
            Restart         = "Success"
            ErrorMessage    = ""  
        }
    }
    catch {
        [PSCustomObject]@{
            Customer        = $container.Customer
            "OCC-Connector" = $container."OCC-Connector"
            Sensorhub       = $container.Name
            SensorName      = $Sensor.name
            SensorID        = $Sensor.aId
            Restart         = "Failed"
            ErrorMessage    = $_

        }
    }
}


