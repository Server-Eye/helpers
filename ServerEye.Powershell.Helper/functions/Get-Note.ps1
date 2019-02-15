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
    $container = Get-SeApiContainer -AuthToken $auth -CId $containerId

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SECustomer -AuthToken $auth -CustomerId $container.customerId
        $connectorName = $container.Name
        $customerName = $customer.companyName
    }
    else {
        $sensorhub = Get-SESensorhub -AuthToken $auth -SensorhubId $containerId
        $sensorhubName = $sensorhub.Name
        $SensorhubId = $Sensorhub.sensorhubId 
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
    }
    
    foreach ($note in $notes) {
        $displayName = "$($note.prename) $($note.surname)".Trim() 
        formatContainerNote -note $note -auth $auth

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

function formatContainerNote($note, $auth) {
    [PSCustomObject]@{
        Message = $note.Message 
        PostedOn = $note.postedOn
        PostedFrom = $displayName
        Email = $note.email
        NoteID = $note.nId
        Sensorhub       = $sensorhubName
        SensorhubId     = $SensorhubId
        'OCC-Connector' = $connectorName
        Customer        = $customerName
    }
}