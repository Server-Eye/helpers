 <#
    .SYNOPSIS
    Removes notifications for a sensor. 
    
    .DESCRIPTION
    This will Remove all notifications for a sensor/Sensorhub.
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be removed.

    .PARAMETER SensorHubId
    The id of the SensorHub for which the notifications should be removed.

    .PARAMETER NotificationId
    The id of the Notification that should be removed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Remove-Notification {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $SensorID,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Alias("ConnectorID")]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $NotificationId,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorID) {
            removeNotificationBySensor -sensorId $SensorId -NotificationID $NotificationId -auth $AuthToken
        }elseif ($SensorhubId) {
            removeNotificationOfSensorhub -SensorhubId $SensorhubId -NotificationID $NotificationId -auth $AuthToken
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function removeNotificationOfSensorhub ($SensorhubId, $NotificationID,$auth) {
    $System = Get-SeApiContainer -cid $SensorhubId -AuthToken $auth
    $Parent = Get-SeApiContainer -cid $System.parentid -AuthToken $auth
    $Customer = Get-SeApiCustomer -cid $System.customerId -AuthToken $auth
    $Notification = Get-SeApiContainerNotificationList -cId $SensorhubId -AuthToken $auth | Where-Object {$_.nId -eq $NotificationID}
    Remove-SeApiContainerNotification -AuthToken $auth -nid $NotificationID -cid $SensorhubId
    [PSCustomObject]@{
        NotificationID = $NotificationId
        Username = if ($user.isGroup -eq $true) {
            $user.surname
        } else{
            ("$($user.prename) $($user.surname)".Trim()) 
        }
        Email = $user.email
        Sensorhub = $System.Name
        'OCC-Connector' = $Parent.Name
        Customer = $Customer.companyName
        Removed = "Yes"
    }

}

function removeNotificationBySensor ($SensorID,$NotificationID, $auth) {
    $Sensor = Get-SeApiAgent -aid $SensorID -AuthToken $auth
    $System = Get-SeApiContainer -cid $Sensor.parentid -AuthToken $auth
    $Parent = Get-SeApiContainer -cid $System.parentid -AuthToken $auth
    $Customer = Get-SeApiCustomer -cid $System.customerId -AuthToken $auth
    $Notification = Get-SeApiAgentNotificationList -aId $SensorID -AuthToken $auth | Where-Object {$_.nId -eq $NotificationID}
    Remove-SeApiAgentNotification -AuthToken $auth -nid $NotificationID -aid $SensorID
    [PSCustomObject]@{
        NotificationID = $NotificationId
        Username = if ($user.isGroup -eq $true) {
            $user.surname
        } else{
            ("$($user.prename) $($user.surname)".Trim()) 
        }
        Email = $user.email
        Sensor = $Sensor.Name
        Sensorhub = $System.Name
        'OCC-Connector' = $Parent.Name
        Customer = $Customer.companyName
        Removed = "Yes"
    }

}
