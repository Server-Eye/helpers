<#
    .SYNOPSIS
    Deletes a Senorhub, all of its historical data and all its agents.

    .PARAMETER SensorhubID
    The id of the Sensorhub.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .EXAMPLE 
    Remove-Sensorhub -SensorhubId "SensorhubID"

     .LINK 
    https://api.server-eye.de/docs/2/#/container/del_container
    

#>

function Remove-Sensorhub {
    [CmdletBinding(DefaultParameterSetName ="")]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory = $true)]
        $SensorhubId,
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        Remove-SEContainer -ContainerID $SensorhubId  -AuthToken $AuthToken
    }

    End {

    }
}

