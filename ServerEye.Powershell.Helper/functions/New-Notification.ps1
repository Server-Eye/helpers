 <#
    .SYNOPSIS
    Create a new notification. 

    .PARAMETER SensorId
    The notification will be added to this sensor.

    .PARAMETER UserId
    The id of the User to be added.

    .PARAMETER SendEmail
    Should the alarm be sent via email. If not specified the default for the user will be selected.
    
    .PARAMETER SendTextmessage
    Should the alarm be sent via text message (SMS). If not specified the default for the user will be selected.
    
    .PARAMETER SendTicket
    Should the alarm be sent to the ticket system. If not specified the default for the user will be selected.

    .PARAMETER DeferId
    The deferid you want to use. To see all posible DeferIDs use the CmdLet Get-SEDispatchTime

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function New-Notification {
    [CmdletBinding(DefaultParameterSetName="ofSensor")]
    Param(
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName='ofSensorhub')]
        [Alias("ConnectorID")]
        $SensorhubId,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $UserId,
        [switch]$SendEmail,
        [switch]$SendTextmessage,
        [switch]$SendTicket,
        $DeferId="",
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        if ($SensorId) {
            newNotificationofSensor -AuthToken $AuthToken -SensorID $SensorId -UserId $UserId -SendEmail $SendEmail.IsPresent -SendTextmessage $SendTextmessage.IsPresent -SendTicket $SendTicket.IsPresent -deferid $deferid
        } elseif ($SensorhubId) {
            newNotificationofContainer -AuthToken $AuthToken -SensorHubID $SensorhubId -UserId $UserId -SendEmail $SendEmail.IsPresent -SendTextmessage $SendTextmessage.IsPresent -SendTicket $SendTicket.IsPresent -deferid $deferid
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function NewNotificationofSensor {
    Param(
    #Parameter help description
    [Parameter(Mandatory=$true)]
    $SensorID,
    [Parameter(Mandatory=$true)]
    $UserId,
    [Parameter(Mandatory=$false)]
    $SendEmail,
    [Parameter(Mandatory=$false)]
    $SendTextmessage,
    [Parameter(Mandatory=$false)]
    $SendTicket,
    [Parameter(Mandatory=$false)]
    $deferid,
    [Parameter(Mandatory=$true)]
    $Authtoken
    )
    $noti = New-SeApiAgentNotification -AuthToken $Authtoken -AId $sensorId -UserId $UserId -Email $SendEmail -Phone $SendTextmessage -Ticket $SendTicket
    formatSensorNotificationNew -Authtoken $Authtoken -notiID $noti.nid -sensorid $noti.aid  -DeferId $deferid
}

function formatSensorNotificationNew($notiID, $Authtoken, $SensorId, $deferid){
    $n = Get-SENotification -SensorId  $SensorId | Where-Object {$_.NotificationId -eq $notiID}
    $sensor = Get-SESensor -SensorId $SensorId
    [PSCustomObject]@{
        Name = $n.Name
        Email = $n.email
        byEmail = $n.byEmail
        byTextmessage = $n.byTextmessage
        byTicket = $n.byTicket
        Defer        = if ($deferId -ne "") {
            Set-SeApiAgentNotification -AuthToken $AuthToken -aid $SensorId -NId $n.NotificationId -DeferId $deferId | Out-Null
            $gnn = Get-SeApiAgentNotificationList -AuthToken $AuthToken -aid $SensorId | Where-Object {$_.Nid -eq $n.NotificationId}
            [PSCustomObject]@{
                Defertime = $gnn.deferTime
                Defername = $gnn.deferName
            }
        }
        else {
            "No Deferid was set."
        }
        NotificationId = $n.NotificationId
        Sensor = $sensor.name
        SensorID = $sensor.SensorId
        Sensorhub = $sensor.sensorhub
        'OCC-Connector' = $sensor.'OCC-Connector'
        Customer = $sensor.customer
    }
}

function NewNotificationofContainer {
    Param(
        #Parameter help description
        [Parameter(Mandatory=$true)]
        $SensorhubID,
        [Parameter(Mandatory=$true)]
        $UserId,
        [Parameter(Mandatory=$false)]
        $SendEmail,
        [Parameter(Mandatory=$false)]
        $SendTextmessage,
        [Parameter(Mandatory=$false)]
        $SendTicket,
        [Parameter(Mandatory=$false)]
        $deferid,
        [Parameter(Mandatory=$true)]
        $Authtoken
        )
    $noti = New-SeApiContainerNotification -AuthToken $Authtoken -CId $SensorhubID -UserId $UserId -Email $SendEmail -Phone $SendTextmessage -Ticket $SendTicket
    $container = Get-SeApiContainer -AuthToken $Authtoken -CId $SensorhubID

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SeApiCustomer -AuthToken $Authtoken -CId $container.customerId
        $connectorName = $container.Name
        $customerName = $customer.companyName
    } else {
        $sensorhub = Get-SESensorhub -AuthToken $Authtoken -SensorhubId $SensorhubID
        $sensorhubName = $sensorhub.Name
        $SensorhubId = $Sensorhub.sensorhubId 
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
    }
    
    formatContainerNotificationNew -notiID $noti.nid -authoken $Authtoken -SensorhubID $noti.cid -deferid $deferId

}

function formatContainerNotificationNew($notiID, $authoken, $SensorhubID, $deferId){
    $n = Get-SENotification -SensorhubId $SensorhubId | Where-Object {$_.NotificationId -eq $notiID}
    [PSCustomObject]@{
        Name = $n.Name
        Email = $n.email
        byEmail = $n.byEmail
        byTextmessage = $n.byTextmessage
        byTicket = $n.byTicket
        Defer        = if ($deferId -ne "") {
            Set-SeApiContainerNotification -AuthToken $AuthToken -cid $SensorhubID -NId $n.NotificationId -DeferId $deferId | Out-Null
            $gnn = Get-SeApiContainerNotificationList -AuthToken $AuthToken -cid $SensorhubID | Where-Object {$_.Nid -eq $n.NotificationId}
            [PSCustomObject]@{
                Defertime = $gnn.deferTime
                Defername = $gnn.deferName
            }
        }
        else {
            "No Deferid was set."
        }
        NotificationId = $n.NotificationId
        Sensorhub = $sensorhubName
        SensorhubId = $SensorhubId
        'OCC-Connector' = $connectorName
        Customer = $customerName
    }
}