<#
    .SYNOPSIS
    Deletes a container, all of its historical data and all its agents.

    .PARAMETER ContainerID
    The id of the container.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .EXAMPLE 
    Remove-Container -containerId "containerID"

     .LINK 
    https://api.server-eye.de/docs/2/#/container/del_container
    

#>
function Remove-Container {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false)]
        $ContainerID,
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($ContainerID) {
            $Container = Get-SEContainer -containerid $ContainerID
            if ($Container.ConnectorID) {
                removeConnector -Container $Container -AuthToken $AuthToken
            }
            if ($Container.SensorhubId) {
                removeSensorhub -Container $Container -AuthToken $AuthToken
            }

        }else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}
function removeConnector ($Container,$AuthToken) {
    Remove-SeApiContainer -AuthToken $AuthToken -cId $container.ConnectorID
    [PSCustomObject]@{
        Customer    = $container.Customer
        Name        = $container.name
        ConnectorID = $container.ConnectorID
        MachineName = $container.machineName
        Removed = "Yes"
    }

}

function removeSensorhub ($container,$AuthToken) {
    Remove-SeApiContainer -AuthToken $AuthToken -cId $Container.SensorhubId
    [PSCustomObject]@{
        Customer = $Container.Customer
        Name = $Container.Name
        SensorhubID = $Container.SensorhubId
        'OCC-Connector' = ($Container."OCC-Connector")
        Removed = "Yes"
    }

}