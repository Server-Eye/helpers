<#
    .SYNOPSIS
    Get sensor details. 
    
    .DESCRIPTION
    List all sensor for a specific sensorhub or get details for a specific sensor.
    
    .PARAMETER Filter
    You can filter the sensors based on the name of the sensor.

    .PARAMETER SensorhubId
    The id of the senorhub for wich you want to list the sensors.

    .PARAMETER SenorId
    The id of a specifc senor. Only this sensor will be show.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Get-Sensor {
    [CmdletBinding(DefaultParameterSetName = "bySensorhub")]
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = "bySensorhub", Position = 0)]
        [string]$Filter,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "bySensorhub")]
        $SensorhubId,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "bySensor")]
        $SensorId,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "bySensorType")]
        $SensorType,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "bySensor")]
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "bySensorhub")]
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "bySensorType")]
        [switch]$ShowFree,
        [Parameter(Mandatory = $false, ParameterSetName = "bySensor")]
        [Parameter(Mandatory = $false, ParameterSetName = "bySensorhub")]
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "bySensorType")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        $agentList = Get-SeApiMyNodesList -Filter agent -AuthToken $AuthToken
        if (!$Global:ServerEyeAgents) {
            $Global:ServerEyeAgents = @()
        }
    }
    
    Process {
        if ($SensorhubId) {
            Write-Debug "SensorhubID will be used $SensorhubId"
            getSensorBySensorhub -sensorhubId $SensorhubId -filter $Filter -auth $AuthToken
        }
        elseif ($SensorId) {
            Write-Debug "SensorID will be used $SensorId"
            getSensorById -sensorId $SensorId -auth $AuthToken
        }
        elseif ($Sensortype) {
            Write-Debug "SensorType will be used $Sensortype"
            $agents = $agentList | Where-Object { $_.agentType -eq $SensorType }
            foreach ($agent in $agents) {
                formatSensorByType -auth $authtoken -agent $agent
            }
        } 
        else {
            Write-Error "Please provide a SensorhubId or a SensorId."
        }
    }

    End {

    }
}

function getSensorBySensorhub ($sensorhubId, $filter, $auth) {
    $agents = Get-SeApiContainerAgentList -AuthToken $auth -CId $sensorhubId 
    $sensorhub = Get-CachedContainer -ContainerID $sensorhubID -AuthToken $auth
    foreach ($sensor in $agents) {
        if ((-not $filter) -or ($sensor.name -like $filter) -or ($sensor.subtype -like $filter)) {
            $sensor = Get-CachedAgent -AgentID $sensor.id -AuthToken $auth
            formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub -agentList $agentList
        }
    }


}
function getSensorById ($sensorId, $auth) {
    $sensor = Get-CachedAgent -AgentID $sensorId -AuthToken $auth
    $sensorhub = Get-CachedContainer -ContainerID $sensor.parentId -AuthToken $auth
    formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub -agentList $agentList
}
function formatSensor($sensor, $sensorhub, $agentlist, $auth) {
    $Global:ServerEyeAgents += $sensor
    $type = $Global:ServerEyeSensorTypes.Get_Item($sensor.type)
    $notification = $agentList | Where-Object { $_.id -eq $sensor.aId }
    $MAC = Get-CachedContainer -AuthToken $auth -ContainerID $sensorhub.parentID
    $customer = Get-CachedCustomer -AuthToken $auth -CustomerId $sensorhub.CustomerId
    $SESensor = [PSCustomObject]@{
        Name            = $sensor.name
        SensorType      = $type.defaultName
        SensorTypeID    = $type.agentType
        SensorId        = $sensor.aId
        Interval        = $sensor.interval
        Error           = $notification.state
        HasNotification = If (!$notification) { "Your are not a Manager of this customer, so we can't show that." }else { $notification.hasNotification }
        Sensorhub       = $sensorhub.name
        'OCC-Connector' = $MAC.Name
        Customer        = $customer.Companyname
        Message         = $notification.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
}

function formatSensorByType($auth, $agent) {
    $type = $Global:ServerEyeSensorTypes.Get_Item($agent.agentType)
    $sensorhub = Get-CachedContainer -ContainerID $agent.parentId -AuthToken $auth
    $MAC = Get-CachedContainer -AuthToken $auth -ContainerID $sensorhub.parentID
    $customer = Get-CachedCustomer -AuthToken $auth -CustomerId $sensorhub.CustomerId
    $SESensor = [PSCustomObject]@{
        Name            = $agent.name
        SensorType      = $type.defaultName
        SensorTypeID    = $type.agentType
        SensorId        = $agent.Id
        Error           = $agent.state
        HasNotification = $agent.hasNotification
        Sensorhub       = $sensorhub.name
        'OCC-Connector' = $MAC.Name
        Customer        = $customer.Companyname
        Message         = $agent.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
}