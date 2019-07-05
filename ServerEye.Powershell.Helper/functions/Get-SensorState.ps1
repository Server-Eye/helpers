 <#
    .SYNOPSIS
    Get sensor state. 
    
    .DESCRIPTION
    Gets the current state of a given sensor.
    
    .PARAMETER IncludeRawDate
    The result will include the raw message data.

    .PARAMETER SenorId
    The id of a specifc senor. Only this sensor will be show.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>

function Get-SensorState {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [switch] $IncludeRawData,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        $withRawData = 'false'
        if ($IncludeRawData) {
            $withRawData = 'true'
        }
        $state = Get-SeApiAgentStateList -Aid $SensorId -AuthToken $AuthToken -Limit 1 -IncludeRawData $withRawData
        $sensor = Get-SESensor -SensorID $SensorId

        [PSCustomObject]@{
                    Name = $sensor.Name
                    SensorType = $Sensor.SensorType
                    SensorId = $state.aId
                    StateId = $state.sId
                    Date = $state.date
                    LastDate = $state.lastDate
                    Error = $state.state -or $state.forceFailed
                    Resolved = $state.resolved
                    SilencedUntil = $state.silencedUntil
                    Raw = $state.raw
                }
    }

    End{

    }
}
