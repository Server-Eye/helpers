 <#
    .SYNOPSIS
    Restarts a sensorhub. 

    .PARAMETER SensorhubId
    The sensorhub id of the sensorhub to be restarted.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>function Restart-Sensorhub {
    [CmdletBinding(DefaultParameterSetName="bySensorhub")]
    Param(
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="bySensorhub")]
        $SensorhubId,
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }

    Process {
        $sensorhub = Get-Sensorhub -SensorhubId $SensorhubId -AuthToken $AuthToken

        $out = $out = New-Object psobject
        $out | Add-Member NoteProperty Sensorhub ($sensorhub.name)
        $out | Add-Member NoteProperty OCC-Connector ($sensorhub.'OCC-Connector')
        $out | Add-Member NoteProperty Customer ($sensorhub.customer)
        $out | Add-Member NoteProperty SensorhubId ($SensorhubId)

        try {
            Restart-SeApiContainer -CId $SensorhubId -AuthToken $AuthToken
            $out | Add-Member NoteProperty Restart ("Success")
            $out | Add-Member NoteProperty ErrorMessage ("")
        } catch {
            $out | Add-Member NoteProperty Restart ("Failed")
            $out | Add-Member NoteProperty ErrorMessage ($_)
        }
        $out
    }

    End {

    }

}

