<#
    .SYNOPSIS
    Restarts a sensorhub. 

    .PARAMETER SensorhubId
    The id of the sensorhub

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Restart-SESensorhub -SensorhubId "4b1aaa1d-9fed-4cb0-bf8f-ed5c540b6a0a"

    Customer      : Wortmann Demo (gesponsert)
    OCC-Connector : Management
    Name          : DC02
    SensorhubId   : f62c53ad-9bc0-4060-8f4a-35030164db5d
    Restart       : Success
    ErrorMessage  :

    
    
#>function Restart-Sensorhub {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the sensorhub.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SensorhubId,
        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        Restart-Container -AuthToken $AuthToken -containerid $SensorhubId
    }

    End {

    }

}

