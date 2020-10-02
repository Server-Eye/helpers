 <#
    .SYNOPSIS
    Removes a Note for a sensor ot sensorhub. 
    
    .DESCRIPTION
    This will remove notes for a sensor/Sensorhub.
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be removed.

    .PARAMETER SensorHubId
    The id of the SensorHub for which the notifications should be removed.

    .PARAMETER NoteID
    The id of the Note that should be removed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Remove-Note {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $SensorID,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $NoteID,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorID) {
            removeNotefromSensor -sensorId $SensorId -Noteid $noteid -auth $AuthToken
        }elseif ($SensorhubId) {
            removeNotefromSensorhub -SensorhubId $SensorhubId -noteid $noteid -auth $AuthToken
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function removeNotefromSensorhub ($SensorhubId, $NoteID, $auth) {
    $Sensorhub = Get-SESensorhub -Sensorhubid $SensorhubId -AuthToken $auth
    $note = Get-SENote -SensorhubId $SensorhubId -AuthToken $auth | Where-Object {$_.NoteId -eq $noteID}
    Remove-SeApiContainerNote -AuthToken $auth -nid $NoteID -cid $SensorhubId
    [PSCustomObject]@{
        NoteID = $NoteID
        Message = $note.Message
        PostedFrom = $note.PostedFrom
        Email = $note.Email
        Sensorhub = $Sensorhub.Name
        'OCC-Connector' = $Sensorhub."OCC-Connector"
        Customer = $Sensorhub.Customer
        Removed = "Yes"
    }

}

function removeNotefromSensor ($SensorID, $NoteID, $auth) {
    $Sensor = Get-SESensor -SensorId $SensorID -AuthToken $auth
    $note = Get-SENote -SensorId $SensorID -AuthToken $auth | Where-Object {$_.NoteId -eq $noteID}
    Remove-SeApiAgentNote -AuthToken $auth -nid $noteID -aid $SensorID
    [PSCustomObject]@{
        NoteID = $NoteID
        Message = $note.Message
        PostedFrom = $note.PostedFrom
        Email = $note.Email
        Sensor = $Sensor.Name
        Sensorhub = $Sensor.Sensorhub
        'OCC-Connector' = $Sensor."OCC-Connector"
        Customer = $Sensor.Customer
        Removed = "Yes"
    }

}
