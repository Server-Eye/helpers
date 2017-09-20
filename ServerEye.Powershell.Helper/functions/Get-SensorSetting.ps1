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
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        getSettingBySensor -sensorId $SensorId -auth $AuthToken
    }

    End{

    }
}

function getSettingBySensor ($sensorId, $auth) {
    $settings = Get-SeApiAgentSettingList -AId $sensorId -AuthToken $auth

    $sensor = Get-Sensor -SensorId $sensorId -AuthToken $auth
    $result = @()
    foreach ($setting in $settings) {
        $out = New-Object psobject
        $out | Add-Member NoteProperty Key ($setting.key)
        $key = $setting.key | Out-String -Stream
        if ($key.ToLower() -eq "password") {
            $out | Add-Member NoteProperty Value ("Password cannot be exported")
            # the encrypted value could be exported but it is useless and breaks the Excel export
        } else {
            $out | Add-Member NoteProperty Value ($setting.value)
        }
        $out | Add-Member NoteProperty SensorId ($sensor.SensorId)
        $out | Add-Member NoteProperty Sensor ($sensor.name)
        $out | Add-Member NoteProperty Sensorhub ($sensor.sensorhub)
        $out | Add-Member NoteProperty OCC-Connector ($sensor.'OCC-Connector')
        $out | Add-Member NoteProperty Customer ($sensor.customer)
        $out
    }
}

