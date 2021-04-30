<#
    .SYNOPSIS
    Get all settings for a sensor. 
    
    .DESCRIPTION
    This will list all settings for a sensor.
    
    .PARAMETER SensorId
    The id of the sensor for which the settings should be listed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Get-SensorSetting {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
        $SensorId,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        getSettingBySensor -sensorId $SensorId -auth $AuthToken
    }

    End {

    }
}

function getSettingBySensor ($sensorId, $auth) {
    $settings = Get-SeApiAgentSettingList -AId $sensorId -AuthToken $auth
    $sensor = Get-CachedAgent -AgentID $sensorId -AuthToken $auth
    $CC = Get-CachedContainer -ContainerID $sensor.parentId -AuthToken $auth
    $MAC = Get-CachedContainer -AuthToken $auth -ContainerID $CC.parentID
    $customer = Get-CachedCustomer -AuthToken $auth -CustomerId $CC.CustomerId

    foreach ($setting in $settings) {
        [PSCustomObject]@{
            Key             = $setting.key
            Value           = if ($setting.key.ToLower() -eq "password") { "Password cannot be exported" }else {
                $setting.value
            }
            SensorId        = $sensor.aid
            Sensor          = $sensor.name
            Sensorhub       = $CC.Name
            "OCC-Connector" = $MAC.Name
            Customer        = $Customer.companyName

        }

    }
}

