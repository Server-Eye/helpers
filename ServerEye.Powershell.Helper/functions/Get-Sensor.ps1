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
        cacheSensorTypes -auth $AuthToken
        $agentList = Get-SeApiMyNodesList -Filter agent -AuthToken $AuthToken
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

function cacheSensorTypes ($auth) {
    $Global:SensorTypes = @{}

    $types = Get-SeApiAgentTypeList -AuthToken $auth
    foreach ($type in $types) {
        $Global:SensorTypes.add($type.agentType, $type)
    }

    $avType = New-Object System.Object
    $avType | Add-Member -type NoteProperty -name agentType -value "72AC0BFD-0B0C-450C-92EB-354334B4DAAB"
    $avType | Add-Member -type NoteProperty -name defaultName -value "Managed Antivirus"
    $avType | Add-Member -type NoteProperty -name forFree -value $true
    $Global:SensorTypes.add($avType.agentType, $avType)

    $pmType = New-Object System.Object
    $pmType | Add-Member -type NoteProperty -name agentType -value "9537CBB5-9023-4248-AFF3-F1ACCC0CE7A4"
    $pmType | Add-Member -type NoteProperty -name defaultName -value "Patchmanagement"
    $pmType | Add-Member -type NoteProperty -name forFree -value $true
    $Global:SensorTypes.add($pmType.agentType, $pmType)

    $suType = New-Object System.Object
    $suType | Add-Member -type NoteProperty -name agentType -value "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C"
    $suType | Add-Member -type NoteProperty -name defaultName -value "Smart Updates"
    $suType | Add-Member -type NoteProperty -name forFree -value $true
    $Global:SensorTypes.add($suType.agentType, $suType)
    
}

function getSensorBySensorhub ($sensorhubId, $filter, $auth) {
    $agents = Get-SeApiContainerAgentList -AuthToken $auth -CId $sensorhubId 
    $sensorhub = Get-SESensorhub -SensorhubId $sensorhubId -AuthToken $auth
    foreach ($sensor in $agents) {
        if ((-not $filter) -or ($sensor.name -like $filter) -or ($sensor.subtype -like $filter)) {
            $sensor = Get-SeApiAgent -AId $sensor.id -AuthToken $auth
            formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub -agentList $agentList
        }
    }


}
function getSensorById ($sensorId, $auth) {
    $sensor = Get-SeApiAgent -AId $sensorId -AuthToken $auth
    $sensorhub = Get-SESensorhub -SensorhubId $sensor.parentId -AuthToken $auth 
    formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub -agentList $agentList
}
function formatSensor($sensor, $sensorhub, $agentlist, $auth) {
    $type = $Global:SensorTypes.Get_Item($sensor.type)
    $notification = $agentList | Where-Object { $_.id -eq $sensor.aId }
    $SESensor = [PSCustomObject]@{
        Name            = $sensor.name
        SensorType      = $type.defaultName
        SensorTypeID    = $type.agentType
        SensorId        = $sensor.aId
        Interval        = $sensor.interval
        Error           = $notification.state
        HasNotification = If (!$notification) { "Your are not a Manager of this customer, so we can't show that." }else { $notification.hasNotification }
        Sensorhub       = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer        = $sensorhub.customer
        Message         = $state.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
}

function formatSensorByType($auth, $agent) {
    $type = $Global:SensorTypes.Get_Item($agent.agentType)
    $sensorhub = Get-SESensorhub -SensorhubId $agent.parentId -AuthToken $auth
    $SESensor = [PSCustomObject]@{
        Name            = $agent.name
        SensorType      = $type.defaultName
        SensorTypeID    = $type.agentType
        SensorId        = $agent.Id
        Error           = $agent.state
        HasNotification = $agent.hasNotification
        Sensorhub       = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer        = $sensorhub.customer
        Message         = $agent.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
}