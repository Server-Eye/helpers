 <#
    .SYNOPSIS
    Removes a Sensor from aSensorhub 
    
    .DESCRIPTION
    Deletes an agent and all of its historical data.
    
    .PARAMETER SensorId
    The id of the agent.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Remove-Sensor -SensorID "7a23fdc5-d270-419e-9b75-e5955b75424d"

    Name          : Windows Defender
    Sensorhub     : WIN10-001
    OCC-Connector : Management
    Customer      : Wortmann Demo (gesponsert)
    Removed       : Yes

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Remove-Sensor {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false)]
        $SensorID,
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorID) {
            removeSensorfromSensorhub -sensorId $SensorId -TagId $TagId -AuthToken $AuthToken
        }else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function removeSensorfromSensorhub ($SensorID,$AuthToken) {
    $Sensor = Get-SESensor -SensorId $sensorid -AuthToken $AuthToken
    Remove-SeApiAgent -AuthToken $AuthToken -aid $sensorid
    [PSCustomObject]@{
        Name = $Sensor.Name
        Sensorhub = $Sensor.Sensorhub
        'OCC-Connector' = ($Sensor."OCC-Connector")
        Customer = $Sensor.Customer
        Removed = "Yes"
    }

}
