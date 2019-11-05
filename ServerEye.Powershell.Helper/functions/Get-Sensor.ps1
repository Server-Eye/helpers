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
        [Parameter(Mandatory=$false,ParameterSetName="bySensor")]
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
        cacheSensorTypes -auth $AuthToken
    }
    
    Process {
        if ($SensorhubId) {
            getSensorBySensorhub -sensorhubId $SensorhubId -filter $Filter -auth $AuthToken
        } elseif ($SensorId) {
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
    $Global:SensorTypes.add($avType.agentType, $avType)

    $pmType = New-Object System.Object
    $pmType | Add-Member -type NoteProperty -name agentType -value "9537CBB5-9023-4248-AFF3-F1ACCC0CE7A4"
    $pmType | Add-Member -type NoteProperty -name defaultName -value "Patchmanagement"
    $Global:SensorTypes.add($pmType.agentType, $pmType)

    $suType = New-Object System.Object
    $suType | Add-Member -type NoteProperty -name agentType -value "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C"
    $suType | Add-Member -type NoteProperty -name defaultName -value "Smart Updates"
    $Global:SensorTypes.add($suType.agentType, $suType)
    
}

function getSensorBySensorhub ($sensorhubId, $filter, $auth) {
    $agents = Get-SeApiContainerAgentList -AuthToken $auth -CId $sensorhubId 
    $sensorhub = Get-SESensorhub -SensorhubId $sensorhubId -AuthToken $auth


    foreach ($sensor in $agents) {
        $count++
        if ((-not $filter) -or ($sensor.name -like $filter) -or ($sensor.SensorTypeID -like $filter)) {
            formatSensor -sensor $sensor -auth $auth -sensorhub $sensorhub
        }
    }


}

function getSensorById ($sensorId, $auth) {
    $sensor = Get-SeApiAgent -AId $sensorId -AuthToken $auth

    $sensorhub = Get-SESensorhub -SensorhubId $sensor.parentId -AuthToken $auth
    
    $state = Get-SeApiAgentStateList -AId $sensorId -AuthToken $auth -IncludeMessage "true" -Format plain
    
    $type = $Global:SensorTypes.Get_Item($sensor.type)
    
    [PSCustomObject]@{

        Name = $sensor.name
        SensorType = $type.defaultName
        SensorTypeID = $type.agentType
        SensorId = $sensor.aId
        Interval = $sensor.interval
        Error = $state.state -or $state.forceFailed
        Sensorhub = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer = $sensorhub.customer
        Message = $state.message
    }

    
}

function formatSensor($sensor, $sensorhub, $auth) {
    $sensorDetails = Get-SeApiAgent -AuthToken $auth -AId $sensor.id

    $type = $Global:SensorTypes.Get_Item($sensorDetails.type)

    [PSCustomObject]@{

        Name = $sensor.name
        SensorType = $type.defaultName
        SensorTypeID = $type.agentType
        SensorId = $sensor.Id
        Interval = $sensorDetails.interval
        Error = $sensor.state -or $sensor.forceFailed
        Sensorhub = $sensorhub.name
        'OCC-Connector' = $sensorhub.'OCC-Connector'
        Customer = $sensorhub.customer
        Message = $sensor.message
    }
}
