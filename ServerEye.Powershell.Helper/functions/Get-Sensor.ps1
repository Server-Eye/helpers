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
    [CmdletBinding(DefaultParameterSetName="bySensorhub")]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub",Position=0)]
        [string]$Filter,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="bySensorhub")]
        $SensorhubId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="bySensor")]
        $SensorId,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName,ParameterSetName="bySensor")]
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName,ParameterSetName="bySensorhub")]
        [switch]$ShowFree,
        [Parameter(Mandatory=$false,ParameterSetName="bySensor")]
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        cacheSensorTypes -auth $AuthToken
    }
    
    Process {
        if ($SensorhubId) {
            Write-Debug "SensorhubID will be used $SensorhubId"
            getSensorBySensorhub -sensorhubId $SensorhubId -filter $Filter -auth $AuthToken
        } elseif ($SensorId) {
            Write-Debug "SensorID will be used $SensorId"
            getSensorById -sensorId $SensorId -auth $AuthToken
        } else {
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
            formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub
        }
    }


}
function getSensorById ($sensorId, $auth) {
    $sensor = Get-SeApiAgent -AId $sensorId -AuthToken $auth
    $sensorhub = Get-SESensorhub -SensorhubId $sensor.parentId -AuthToken $auth 
    $state = Get-SeApiAgentStateList -AId $sensorId -AuthToken $auth -IncludeMessage "true" -Format plain
    $type = $Global:SensorTypes.Get_Item($sensor.type)
    $notification = Get-SeApiMyNodesList -Filter agent -AuthToken $auth | Where-Object {$_.id -eq $sensor.aId}
    $SESensor = [PSCustomObject]@{
        Name = $sensor.name
        SensorType = $type.defaultName
        SensorTypeID = $type.agentType
        SensorId = $sensor.aId
        Interval = $sensor.interval
        Error = $state.state -or $state.forceFailed
        HasNotification = $notification.hasNotification
        Sensorhub = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer = $sensorhub.customer
        Message = $state.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
  
}
function formatSensor($sensor, $sensorhub, $auth,$notification) {
    $type = $Global:SensorTypes.Get_Item($sensor.type)
    $notification = Get-SeApiMyNodesList -Filter agent -AuthToken $auth | Where-Object {$_.id -eq $sensor.aId}
    $SESensor = [PSCustomObject]@{
        Name = $sensor.name
        SensorType = $type.defaultName
        SensorTypeID = $type.agentType
        SensorId = $sensor.Id
        Interval = $sensor.interval
        Error = $sensor.state -or $sensor.forceFailed
        HasNotification = $notification.hasNotification
        Sensorhub = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer = $sensorhub.customer
        Message = $sensor.message
    }
    if ($ShowFree) {
        Add-Member -MemberType NoteProperty -Name forFree -Value $type.forFree -InputObject $SESensor
    }
    Return $SESensor
}