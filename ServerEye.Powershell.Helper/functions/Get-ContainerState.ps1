<#
    .SYNOPSIS
    Get the current state of this container.
    
    .DESCRIPTION
    Gets the current state of a Sensorhub.
    
    .PARAMETER containerid
    The id of the container.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    # Shows a OCC Connector State. 
    Get-SEContainerState -containerid "OCC Connector ID"

    Customer      : Wortmann Demo (gesponsert)
    Name          : Management
    ConnectorID   : 03eb26d3-e6eb-498e-b437-6ae810fbd5c5
    StateId       : 26384049
    Date          : 02.09.2019 08:31:44
    LastDate      : 03.09.2019 08:04:05
    Error         : False
    Resolved      : False
    SilencedUntil :


    .EXAMPLE 
    # Shows a Sensorhub State. 
    Get-SEContainerState -containerid "Senorhub ID"

    Customer      : Wortmann Demo (gesponsert)
    Name          : DASISRV
    Connector     : Management
    SensorhubID   : 786fc0c1-f83f-4245-9311-f85d7550d828
    StateId       : 26267775
    Date          : 27.08.2019 19:58:06
    LastDate      : 03.09.2019 08:06:45
    Error         : False
    Resolved      : False
    SilencedUntil :

    .LINK 
    https://api.server-eye.de/docs/2/#/container/list_container_state
#>

function Get-ContainerState {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
        [Alias("ConnectorID", "SensorhubId")]
        $containerid,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        $Limit = 1,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        $start,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        $end,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken

    }
    
    Process {
        $container = Get-SEContainer -containerid $containerid
        
        if ($start -and $end) {
            $states = Get-SeApiContainerStateList -cId $containerid -AuthToken $AuthToken -IncludeHints "true" -IncludeMessage "true" -Start ([DateTimeOffset](($start).ToUniversalTime())).ToUnixTimeMilliseconds() -End ([DateTimeOffset](($end).ToUniversalTime())).ToUnixTimeMilliseconds()
        }
        else {
            $states = Get-SeApiContainerStateList -cId $containerid -AuthToken $AuthToken -Limit $Limit -IncludeHints "true" -IncludeMessage "true"
        }
        foreach ($state in $states) {
            if ($container.ConnectorID) {
                forea
                formatOCCConnectorState -container $container -state $state
            }
            if ($container.SensorhubId) {
                formatSensorhubState -container $container -state $state
            }
        }

    }

    End {

    }
}

function formatOCCConnectorState($container, $state) {
    [PSCustomObject]@{
        Customer      = $container.Customer
        Name          = $container.name
        ConnectorID   = $container.ConnectorID
        StateId       = $state.sId
        Date          = (Convert-SEDBTime -date ($state.Date))
        LastDate      = (Convert-SEDBTime -date ($state.lastDate))
        Error         = $state.state -or $state.forceFailed
        Message       = $state.message
        Resolved      = $state.resolved
        SilencedUntil = if (!$state.silencedUntil) { $state.silencedUntil }else { (Convert-SEDBTime -date ($state.silencedUntil)) }
    }
}
function formatSensorhubState($container, $state) {
    [PSCustomObject]@{
        Customer      = $container.Customer
        Name          = $container.name
        Connector     = $container."OCC-Connector"
        SensorhubID   = $container.SensorhubId
        StateId       = $state.sId
        Date          = (Convert-SEDBTime -date ($state.Date))
        LastDate      = (Convert-SEDBTime -date ($state.lastDate))
        Error         = $state.state -or $state.forceFailed
        Message       = $state.message
        Resolved      = $state.resolved
        SilencedUntil = if (!$state.silencedUntil) { $state.silencedUntil }else { (Convert-SEDBTime -date ($state.silencedUntil)) }
    }
}
