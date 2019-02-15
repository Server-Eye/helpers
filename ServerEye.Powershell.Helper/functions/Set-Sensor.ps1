 <#
    .SYNOPSIS
    Change an Sensor. 
    
    .DESCRIPTION
    This will set the value of one setting for a sensor.
    
    .PARAMETER SensorId
    The id of the agent.

    .PARAMETER Name
    The name to display to the user.

    .PARAMETER Interval
    The interval in minutes. The agent will be executed every X minutes.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Set-Sensor {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [parameter(Mandatory=$false)]
        [string]$Name = "",
        [Parameter(Mandatory=$false)]
        [int]$Interval = "",
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($name -ne "") {
            Set-SeApiAgent -AId $SensorId -Name $Name -AuthToken $AuthToken
        }
        if ($Interval -ne "") {
            Set-SeApiAgent -AId $SensorId -Interval $Interval -AuthToken $AuthToken
        }
        
    }
}
