 <#
    .SYNOPSIS
    Set one Tag for a sensor. 
    
    .DESCRIPTION
    This will set a Tag for the Sensor
    
    .PARAMETER SensorId
    The id of the sensor for which the settings should be altered.

    .PARAMETER TagID
    The ID of the Tag, to View Tags use Get-SETag
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Set-SensorTag {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [parameter(Mandatory=$true)]
        $TagID,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $Sensor = Get-SESensor -AuthToken $AuthToken -SensorId $SensorId
        New-SeApiAgentTag -AuthToken $AuthToken -AId $SensorId -TId $tagId
        $sensorname = $sensor.name
        Write-Host "CmdLet is deprecated please use Set-SETag instead"
        Write-Host "Tag wurde gesetzt beim Sensor $sensorname"


    }
}



