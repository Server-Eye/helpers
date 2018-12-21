 <#
    .SYNOPSIS
    Get a list of all Tags from a Sensor.

    .DESCRIPTION
    Get a list of all Tags.

    .PARAMETER SenorId
    The id of a specifc senor. Only this sensor will be show.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-Sensortag {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
            $Tags = Get-SeApiAgentTagList -AId $SensorId -AuthToken $authtoken
            $Sensor = Get-SeApiAgent -AId $sensorId -AuthToken $AuthToken
            $sensorhub = Get-SESensorhub -SensorhubId $Sensor.parentId -AuthToken $auth
        
                [PSCustomObject]@{
                    Sensorname = $sensor.Name
                    SensorId = $sensor.aId
                    Sensorhub = $sensorhub.name
                    'OCC-Connector' = $sensorhub.'OCC-Connector'
                    Customer = $sensorhub.customer
                    Tag = $tags.Name
                }
            
    }
}




