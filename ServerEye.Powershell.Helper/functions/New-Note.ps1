 <#
    .SYNOPSIS
    Create a new Note.

    .DESCRIPTION
    The Note will be added to the senosor or sensorhub.

    .PARAMETER SensorId
    The id of the Sensor.

    .PARAMETER SensorhubID
    The id of the container.

    .PARAMETER message
    The note's message.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function New-Note {
    [CmdletBinding(DefaultParameterSetName="ofSensor")]
    Param(
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensorhub')]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensorhub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensor')]
        [string]$message,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        if ($SensorId) {
            newNoteforSensor -AuthToken $AuthToken -SensorID $SensorId -message $message
        } elseif ($SensorhubId) {
            newNoteforContainer -AuthToken $AuthToken -SensorHubID $SensorhubId -message $message
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function newNoteforSensor {
    Param(
    #Parameter help description
    [Parameter(Mandatory=$true)]
    $SensorID,
    [Parameter(Mandatory=$true)]
    $message,
    [Parameter(Mandatory=$true)]
    $Authtoken
    )
    $note = New-SeApiAgentNote -AuthToken $Authtoken -AId $sensorId -message $message
    formatSensorNoteNew -Authtoken $Authtoken -noteID $note.nid -sensorid $note.aid
}

function formatSensorNoteNew($noteID, $Authtoken, $SensorID){
    $n = Get-SENote -SensorId  $SensorId | Where-Object {$_.NoteID -eq $noteID}
    $sensor = Get-SESensor -SensorId $SensorId
    [PSCustomObject]@{
        Message = $n.message
        PostedOn  = $n.PostedOn
        PostedFrom = $n.PostedFrom
        Email = $n.Email
        NoteId = $n.NoteID
        Sensor = $sensor.name
        SensorID = $sensor.SensorId
        Sensorhub = $sensor.sensorhub
        'OCC-Connector' = $sensor.'OCC-Connector'
        Customer = $sensor.customer
    }
}

function newNoteforContainer {
    Param(
        #Parameter help description
        [Parameter(Mandatory=$true)]
        $SensorhubID,
        [Parameter(Mandatory=$true)]
        $message,
        [Parameter(Mandatory=$true)]
        $Authtoken
        )
    $note = New-SeApiContainerNote -AuthToken $Authtoken -CId $SensorhubID -Message $message    
    $container = Get-SeApiContainer -AuthToken $Authtoken -CId $SensorhubID

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SeApiCustomer -AuthToken $Authtoken -CId $container.customerId
        $connectorName = $container.Name
        $customerName = $customer.companyName
    } else {
        $sensorhub = Get-SESensorhub -AuthToken $Authtoken -SensorhubId $SensorhubID
        $sensorhubName = $sensorhub.Name
        $SensorhubId = $Sensorhub.sensorhubId 
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
    }
    
    formatContainerNotenNew -noteID $note.nid -authoken $Authtoken -SensorhubID $note.cid

}

function formatContainerNotenNew($noteID, $authoken, $SensorhubID){
    $n = Get-SENote -SensorhubId $SensorhubId | Where-Object {$_.NoteId -eq $noteID}
    [PSCustomObject]@{
        Message = $n.message
        PostedOn  = $n.PostedOn
        PostedFrom = $n.PostedFrom
        Email = $n.Email
        NoteId = $n.NoteID
        Sensorhub = $sensorhubName
        SensorhubId = $SensorhubId
        'OCC-Connector' = $connectorName
        Customer = $customerName
    }
}