 <#
    .SYNOPSIS
    Changed a given Notification.
    
    .DESCRIPTION
    Set the given Parameter for the Notification
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be changed.

    .PARAMETER SensorhubId
    The id of the sensorhub for which the notifications should be changed.

    .PARAMETER NotificationId
    The id of the notification that should be changed.

    .PARAMETER userId
    The id of the user or group that should receive a notification.

    .PARAMETER SendEmail
    Should the alarm be sent via email.
    
    .PARAMETER SendTextmessage
    Should the alarm be sent via text message (SMS).
    
    .PARAMETER SendTicket
    Should the alarm be sent to the ticket system.

    .PARAMETER DeferId
    The deferid you want to use. To see all posible DeferIDs use the CmdLet Get-SEDispatchTime

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
   
#>
function Set-Notification {
    Param(
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensorhub')]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensorhub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensor')]
        $NotificationId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $userId,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        [switch]$SendEmail,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        [switch]$SendTextmessage,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        [switch]$SendTicket,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        $DeferId="",
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='ofSensor')]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorId) {
            setNotificationofSensor -AuthToken $AuthToken -SensorID $SensorId -NotificationId $NotificationId -userid $userId -SendEmail $SendEmail.IsPresent -SendTextmessage $SendTextmessage.IsPresent -SendTicket $SendTicket.IsPresent -deferid $deferid
        } elseif ($SensorhubId) {
            SetNotificationofContainer -AuthToken $AuthToken -SensorHubID $SensorhubId -NotificationId $NotificationId -userId $userId -SendEmail $SendEmail.IsPresent -SendTextmessage $SendTextmessage.IsPresent -SendTicket $SendTicket.IsPresent -deferid $deferid
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function setNotificationofSensor {
    Param(
    #Parameter help description
    [Parameter(Mandatory=$true)]
    $SensorID,
    [Parameter(Mandatory=$true)]
    $NotificationId,
    [Parameter(Mandatory=$false)]
    $userId,
    [Parameter(Mandatory=$false)]
    $SendEmail,
    [Parameter(Mandatory=$false)]
    $SendTextmessage,
    [Parameter(Mandatory=$false)]
    $SendTicket,
    [Parameter(Mandatory=$false)]
    $deferid,
    [Parameter(Mandatory=$true)]
    $authtoken
    )
    $noti = Set-SeApiAgentNotification -AuthToken $authtoken -AId $sensorId -NId $NotificationId -userId $userId -Email $SendEmail -Phone $SendTextmessage -Ticket $SendTicket -DeferId $deferid
    formatSensorNotificationset -notiID $noti.id -authoken $authtoken -sensorid $noti.parent_id
}

function formatSensorNotificationset($notiID, $authtoken, $SensorId){
    $n = Get-SENotification -SensorId  $SensorId | Where-Object {$_.NotificationId -eq $notiID}
    $sensor = Get-SESensor -SensorId $SensorId -AuthToken $authtoken
    [PSCustomObject]@{
        Name = $n.Name
        Email = $n.email
        byEmail = $n.byEmail
        byTextmessage = $n.byTextmessage
        byTicket = $n.byTicket
        Delay = if ($n.Delay) {
            $n.Delay
        } else {
            "0"
        }
        NotificationId = $n.NotificationId
        Sensor = $sensor.name
        SensorID = $sensor.SensorId
        Sensorhub = $sensor.sensorhub
        'OCC-Connector' = $sensor.'OCC-Connector'
        Customer = $sensor.customer
    }
}

function SetNotificationofContainer {
    Param(
        #Parameter help description
        [Parameter(Mandatory=$true)]
        $SensorhubID,
        [Parameter(Mandatory=$true)]
        $NotificationId,
        [Parameter(Mandatory=$false)]
        $userId,
        [Parameter(Mandatory=$false)]
        $SendEmail,
        [Parameter(Mandatory=$false)]
        $SendTextmessage,
        [Parameter(Mandatory=$false)]
        $SendTicket,
        [Parameter(Mandatory=$false)]
        $deferid,
        [Parameter(Mandatory=$true)]
        $authtoken
        )
    $noti = Set-SeApiContainerNotification -AuthToken $authtoken -CId $SensorhubID -NId $NotificationId -userId $userId -Email $SendEmail -Phone $SendTextmessage -Ticket $SendTicket -DeferId $deferid
    $container = Get-SeApiContainer -AuthToken $authtoken -CId $SensorhubID

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SeApiCustomer -AuthToken $authtoken -CId $container.customerId
        $connectorName = $container.Name
        $customerName = $customer.companyName
    } else {
        $sensorhub = Get-SESensorhub -AuthToken $auth -SensorhubId $SensorhubID
        $sensorhubName = $sensorhub.Name
        $SensorhubId = $Sensorhub.sensorhubId 
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
    }
    
    formatContainerNotificationSet -notiID $noti.id -authoken $authtoken -SensorhubID $noti.parent_id

}

function formatContainerNotificationSet($notiID, $authoken, $SensorhubID){
    $n = Get-SENotification -SensorhubId $SensorhubId -authoken $authtoken | Where-Object {$_.NotificationId -eq $notiID}
    [PSCustomObject]@{
        Name = $n.Name
        Email = $n.email
        byEmail = $n.byEmail
        byTextmessage = $n.byTextmessage
        byTicket = $n.byTicket
        Delay = if ($n.Delay) {
            $n.Delay
        } else {
            "0"
        }
        NotificationId = $n.NotificationId
        Sensorhub = $sensorhubName
        SensorhubId = $SensorhubId
        'OCC-Connector' = $connectorName
        Customer = $customerName
    }
}