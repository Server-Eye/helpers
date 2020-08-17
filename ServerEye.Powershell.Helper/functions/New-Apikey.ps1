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
function New-Apikey {
    [CmdletBinding(DefaultParameterSetName="Credentail")]
    Param(
        [Parameter(Mandatory = $true,
            ParameterSetName = "APIKey",
            HelpMessage = "A valid API key. If this is provided, any other parameter is ignored!")] 
        [string]$Apikey,

        [Parameter(Mandatory = $true,
            ParameterSetName = "Credential",
            HelpMessage = "Email address and Password of the user to logincls.")] 
        [pscredential] $Credentials,

        [Parameter(Mandatory = $false,
            ParameterSetName = "Credential",
            HelpMessage = "If the user has two-factor enabled you have to send the 6-digit code during the auth process. The HTTP code 420 will tell you that two-factor is enabled.")] 
        [string] $Code,

        [Parameter(Mandatory = $false,
        ParameterSetName = "Credential",
        HelpMessage = "What kind of key do you want?")] 
        [Parameter(Mandatory = $false,
        ParameterSetName = "APIKey",
        HelpMessage = "What kind of key do you want?")] 
        [ValidateSet("user","customer")]
        [string] $type = "user",

        [Parameter(Mandatory = $false,
        ParameterSetName = "Credential",
        HelpMessage = "Give the key a name.")] 
        [Parameter(Mandatory = $false,
        ParameterSetName = "APIKey",
        HelpMessage = "Give the key a name.")] 
        [string] $name,
        
        [Parameter(Mandatory = $false,
        ParameterSetName = "Credential",
        HelpMessage = "Do you want this key to expire?, (JavaScript UTC timestamp), Example Value:1417600672987,")] 
        [Parameter(Mandatory = $false,
        ParameterSetName = "APIKey",
        HelpMessage = "Do you want this key to expire?, (JavaScript UTC timestamp), Example Value:1417600672987")] 
        [string] $validUntil,

        [Parameter(Mandatory = $false,
        ParameterSetName = "Credential",
        HelpMessage = "DIs this key meant to be used only a couple of times?"] 
        [Int] $maxUses
        
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        if ($SensorId) {
            newNoteforSensor -AuthToken $AuthToken -SensorID $SensorId -message $message
        } elseif ($containerID) {
            newNoteforContainer -AuthToken $AuthToken -containerID $containerID -message $message
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
        $containerID,
        [Parameter(Mandatory=$true)]
        $message,
        [Parameter(Mandatory=$true)]
        $Authtoken
        )
    $note = New-SeApiContainerNote -AuthToken $Authtoken -CId $containerID -Message $message    
    $container = Get-SeApiContainer -AuthToken $Authtoken -CId $containerID

    Write-Debug $container

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SECustomer -CustomerId $container.customerId
        $connectorName = $container.Name
        $connectorID = $container.cid 
        $customerName = $customer.Name
        formatConnectorNoteNew -noteID $note.nid -authoken $Authtoken -containerID $note.cid
    } else {
        $sensorhub = Get-SESensorhub -AuthToken $Authtoken -SensorhubId $containerID
        $sensorhubName = $sensorhub.Name
        $SensorhubId = $Sensorhub.sensorhubId 
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
        formatSensorhubNoteNew -noteID $note.nid -authoken $Authtoken -containerID $note.cid
    }
    

}

function formatSensorhubNoteNew($noteID, $authoken, $containerID) {
    $n = Get-SENote -containerID $containerID | Where-Object {$_.NoteId -eq $noteID}
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
function formatConnectorNoteNew($noteID, $authoken, $containerID) {
    $n = Get-SENote -containerID $containerID | Where-Object {$_.NoteId -eq $noteID}
    [PSCustomObject]@{
        Message = $note.Message 
        PostedOn = $note.postedOn
        PostedFrom = $displayName
        Email = $note.email
        NoteID = $note.nId
        'OCC Connector' = $connectorName
        ConnectorID = $connectorID
        Customer        = $customerName
    }
}