<#
    .SYNOPSIS
    Get Notes for a sensor or a sensorhub. 
    
    .DESCRIPTION
    This will list all Notes for a sensor or a sensorhub.
    
    .PARAMETER SensorId
    The id of the agent.

    .PARAMETER SensorhubId
    The id of the container.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-Note {
    [CmdletBinding(DefaultParameterSetName = 'ofSensor')]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true, ParameterSetName = 'ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true, ParameterSetName = 'ofSensorhub')]
        [Alias("ConnectorID")]
        $SensorhubId,
        [Parameter(Mandatory = $false, ParameterSetName = 'ofSensorhub')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ofSensor')]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorId) {
            getNotesfromSensor -sensorId $SensorId -auth $AuthToken
        }
        elseif ($SensorhubId) {
            getNoteOfContainer -containerID $SensorhubId -auth $AuthToken
        }
        else {
            Write-Error "Unsupported input"
        }
        
    }

    End {

    }
}

function getNoteOfContainer ($containerID, $auth) {
    $notes = Get-SeApiContainerNoteList -AuthToken $auth -CId $containerId
    $Container = Get-CachedContainer -ContainerID $ContainerID -AuthToken $Auth
    $customer = Get-CachedCustomer -customerid $container.customerid -authtoken $Auth
    if ($container.type -eq 0) {
        foreach ($note in $notes) {
            $displayName = "$($note.prename) $($note.surname)".Trim() 
            formatConnectorNote -note $note -auth $auth -container $container -customer $Customer
    
        }
    }
    else {
        $MAC = Get-CachedContainer -ContainerID $Container.parentId -AuthToken $AuthToken
        foreach ($note in $notes) {
            $displayName = "$($note.prename) $($note.surname)".Trim() 
            formatSensorhubNote -note $note -auth $auth -container $container -customer $Customer -mac $mac
    
        }
    }
}

function getNotesfromSensor ($sensorId, $auth) {
    $notes = Get-SeApiAgentNoteList -AuthToken $auth -AId $sensorId
    $sensor = Get-SESensor -SensorId $sensorId -AuthToken $auth

    foreach ($note in $notes) {
        $displayName = "$($note.prename) $($note.surname)".Trim() 
            formatSensorNote -note $note -auth $auth -sensor $sensor
    }

}

function formatSensorNote($note, $auth, $sensor) {
    [PSCustomObject]@{
        Message = $note.Message 
        PostedOn = $note.postedOn
        PostedFrom = $displayName
        Email = $note.email
        NoteID = $note.nId
        Sensor          = $sensor.name
        SensorID        = $sensor.SensorId
        Sensorhub       = $sensor.sensorhub
        'OCC-Connector' = $sensor.'OCC-Connector'
        Customer        = $sensor.customer
    }
}

function formatSensorhubNote($note,$container,$customer,$mac, $auth) {

    [PSCustomObject]@{
        Message = $note.Message 
        PostedOn = $note.postedOn
        PostedFrom = $displayName
        Email = $note.email
        NoteID = $note.nId
        Sensorhub       = $container.name
        SensorhubId     = $container.cid
        'OCC Connector' = $mac.name
        Customer        = $Customer.companyname
    }
}
function formatConnectorNote($note,$container,$customer, $auth) {
    [PSCustomObject]@{
        Message = $note.Message 
        PostedOn = $note.postedOn
        PostedFrom = $displayName
        Email = $note.email
        NoteID = $note.nId
        'OCC Connector' = $Container.name
        ConnectorID = $Container.cid
        Customer        = $customer.companyname
    }
}