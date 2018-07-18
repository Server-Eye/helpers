 <#
    .SYNOPSIS
    Get notifications for a sensor. 
    
    .DESCRIPTION
    This will list all notifications for a sensor.
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be removed.

    .PARAMETER SensorHubId
    The id of the SensorHub for which the notifications should be removed.

    .PARAMETER NotificationId
    The id of the Notification that should be removed.

    .PARAMETER Name
    The Fullname (Prename and Surname) of the User in the Notification.

    .PARAMETER Email
    The Email of the User in the Notification.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Remove-Notification {
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $SensorID,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $NotificationId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $Name,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorHub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $Email,
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
    $System = Get-SeApiContainer -cid $SensorhubId -auth $auth
    $Parent = Get-SeApiContainer -cid $System.parentid -auth $auth
    $Customer = Get-SeApiCustomer -cid $System.customerId -auth $auth
    Remove-SeApiContainerNotification -AuthToken $auth -nid $NotificationID -cid $SensorhubId
    [PSCustomObject]@{
        NotificationID = $NotificationId
        Username = $Name
        Email = $Email
        Sensorhub = $System.Name
        'OCC-Connector' = $Parent.Name
        Customer = $Customer.companyName
        Removed = "Yes"
    }

}

function removeNotificationBySensor ($SensorID,$NotificationID, $auth) {
    $Sensor = Get-SeApiAgent -aid $SensorID -auth $auth
    $System = Get-SeApiContainer -cid $Sensor.parentid -auth $auth
    $Parent = Get-SeApiContainer -cid $System.parentid -auth $auth
    $Customer = Get-SeApiCustomer -cid $System.customerId -auth $auth
    Remove-SeApiAgentNotification -AuthToken $auth -nid $NotificationID -aid $SensorID
    [PSCustomObject]@{
        NotificationID = $NotificationId
        Username = $Name
        Email = $Email
        Sensor = $Sensor.Name
        Sensorhub = $System.Name
        'OCC-Connector' = $Parent.Name
        Customer = $Customer.companyName
        Removed = "Yes"
    }

}
