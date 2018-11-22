 <#
    .SYNOPSIS
    Set a Tag for a Sensor/Sensorhub or OCC-Connector
    
    .DESCRIPTION
    This will remove a Tag for a Sensor/Sensorhub or OCC-Connector.
    
    .PARAMETER SensorId
    The id of the sensor for which the tag should be removed from.

    .PARAMETER SensorHubId
    The id of the SensorHub for which the tag should be removed from.

    .PARAMETER TagId
    The id of the Tag that should be removed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Set-Tag {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $SensorID,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        $SensorhubId,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofConnector')]
        $ConnectorId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub',Position=0)]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor',Position=0)]
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofConnector',Position=0)]
        $TagId,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        [parameter(Mandatory=$false,ParameterSetName='ofConnector')]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorID) {
            setTagtoSensor -sensorId $SensorId -TagId $TagId -AuthToken $AuthToken
        }elseif ($SensorhubId) {
            setTagtoSensorhub -SensorhubId $SensorhubId -TagId $TagId -AuthToken $AuthToken
        }elseif ($ConnectorId) {
            setTagtoConnector -ConnectorId $ConnectorId -TagId $TagId -AuthToken $AuthToken
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function setTagtoSensor ($SensorID,$TagId, $AuthToken) {
    $Sensor = Get-SESensor -AuthToken $AuthToken -SensorId $SensorId
    $Tag = Get-SETag -AuthToken $AuthToken | Where-Object {$_.TagID -eq $Tagid}
    New-SeApiAgentTag -AuthToken $AuthToken -tId $TagId -aid $SensorID
    [PSCustomObject]@{
        TagId = $TagID
        Tagname = $tag.Name
        Sensor = $Sensor.Name
        Sensorhub = $Sensor.Sensorhub
        'OCC-Connector' = ($Sensor."OCC-Connector")
        Customer = $Sensor.Customer
        Set = "Yes"
    }

}

function setTagtoSensorhub ($SensorhubId, $TagId, $AuthToken) {
    $Sensorhub = Get-SESensorhub -AuthToken $AuthToken -SensorhubId $SensorhubId
    $Tag = Get-SETag -AuthToken $AuthToken | Where-Object {$_.TagID -eq $Tagid}
    New-SeApiContainerTag -AuthToken $AuthToken -tId $TagId -cid $SensorhubId
    [PSCustomObject]@{
        TagID = $TagId
        Tagname = $tag.Name
        Sensorhub = $Sensorhub.Name
        'OCC-Connector' = ($Sensorhub."OCC-Connector")
        Customer = $Sensorhub.Customer
        Set = "Yes"
    }

}

function setTagtoConnector ($ConnectorId, $TagId, $AuthToken) {
    $Connector = Get-SEOCCConnector -AuthToken $AuthToken -ConnectorId $ConnectorId
    $Tag = Get-SETag -AuthToken $AuthToken | Where-Object {$_.TagID -eq $Tagid}
    New-SeApiContainerTag -AuthToken $AuthToken -tId $TagId -cid $ConnectorId
    [PSCustomObject]@{
        TagID = $TagId
        Tagname = $tag.Name
        'OCC-Connector' = $Connector.Name
        Customer = $Connector.Customer
        Set = "Yes"
    }

}



