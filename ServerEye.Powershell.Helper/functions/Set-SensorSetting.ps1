 <#
    .SYNOPSIS
    Set one settings for a sensor. 
    
    .DESCRIPTION
    This will set the value of one setting for a sensor.
    
    .PARAMETER SensorId
    The id of the sensor for which the settings should be altered.

    .PARAMETER Key
    The settings key to identify the setting.

    .PARAMETER Value
    The new value of the setting.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Set-SensorSetting {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess)]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $Key,
        [Parameter(Mandatory=$true)]
        $Value,
        [Parameter(Mandatory=$false)]
        $AuthToken,
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        $setting = Get-SensorSetting -SensorId $SensorId -AuthToken $AuthToken | Where-Object Key -eq $Key
        if (-not $setting) {
            Write-Error "A setting with this key does not exist"
            return
        } 
        
        if ($PSCmdlet.ShouldProcess("Key: $Key", "Changing from '$($setting.value)' to '$value'")) {
            doSetSensorSetting -SensorId $SensorId -Key $key -Value $Value -AuthToken $AuthToken
        }
    }
}

function doSetSensorSetting($SensorId, $Key, $Value, $AuthToken) {
    $sensor = Get-Sensor -SensorId $SensorId -AuthToken $AuthToken
    $updatedSetting = Set-SeApiAgentSetting -AuthToken $AuthToken -AId $SensorId -Key $Key -Value $Value

    $out = New-Object psobject
    $out | Add-Member NoteProperty Key ($setting.key)
    $key = $setting.key | Out-String -Stream
    if ($key.ToLower() -eq "password") {
        $out | Add-Member NoteProperty Value ("Password cannot be exported")
        # the encrypted value could be exported but it is useless and breaks the Excel export
    } else {
        $out | Add-Member NoteProperty Value ($updatedSetting.value)
    }
    $out | Add-Member NoteProperty SensorId ($sensor.SensorId)
    $out | Add-Member NoteProperty Sensor ($sensor.name)
    $out | Add-Member NoteProperty Sensorhub ($sensor.sensorhub)
    $out | Add-Member NoteProperty OCC-Connector ($sensor.'OCC-Connector')
    $out | Add-Member NoteProperty Customer ($sensor.customer)
    $out

}


