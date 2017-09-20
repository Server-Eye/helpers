 <#
    .SYNOPSIS
    Get notifications for a sensor. 
    
    .DESCRIPTION
    This will list all notifications for a sensor.
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be listed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Get-SENotification $SensorId=12345-6789-ABCDE

    Name           : Andreas Behr
    Email          : andy@server-eye.de
    byEmail        : True
    byTextmessage  : False
    byTicket       : False
    Delay          : 0
    NotificationId : 01234-5678-ABCDE
    Sensor         : Ping
    Sensorhub      : SERV2012R2
    OCC-Connector  : lab.server-eye.local
    Customer       : Systemmanager IT

    .EXAMPLE
    Get-SECustomer "Systemmanager*" | Get-SESensorhub | Get-SESensor | Get-SENotification | Format-Table

    Name            Email                 byEmail byTextmessage byTicket Delay NotificationId   Sensor Sensorhub  OCC-Connector        Customer
    ----            -----                 ------- ------------- -------- ----- --------------   ------ ---------  -------------        --------
    Andreas Behr    andy@server-eye.de    False   False         False    0     1234-56789-ABCDE Ping   SERV2012R2 lab.server-eye.local Systemmanger IT
    Patrick Schmidt patrick@server-eye.de False   False         False    0     1234-56789-ABCDE Ping   SERV2012R2 lab.server-eye.local Systemanager IT
    
#>
function Get-Notification {
    [CmdletBinding(DefaultParameterSetName='ofSensor')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='ofSensorhub')]
        $SensorhubId,
        [Parameter(Mandatory=$false,ParameterSetName='ofSensorhub')]
        [Parameter(Mandatory=$false,ParameterSetName='ofSensor')]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorId) {
            getNotificationBySensor -sensorId $SensorId -auth $AuthToken
        } elseif ($SensorhubId) {
            getNotificationOfContainer -containerID $SensorhubId -auth $AuthToken
        } else {
            Write-Error "Unsupported input"
        }
        
    }

    End{

    }
}

function getNotificationOfContainer ($containerID, $auth) {
    $notifies = Get-SeApiContainerNotificationList -AuthToken $auth -CId $containerId
    $container = Get-SeApiContainer -AuthToken $auth -CId $containerId

    $sensorhubName = ""
    $connectorName = ""
    $customerName = ""
    
    if ($container.type -eq "0") {
        $customer = Get-SeApiCustomer -AuthToken $auth -CId $container.customerId
        $connectorName = $container.Name
        $customerName = $customer.companyName
    } else {
        $sensorhub = Get-Sensorhub -AuthToken $auth -SensorhubId $containerId
        $sensorhubName = $sensorhub.Name
        $connectorName = $sensorhub.'OCC-Connector'
        $customerName = $sensorhub.Customer
    }
    
    foreach ($notify in $notifies) {
        $displayName = "$($notify.prename) $($notify.surname)".Trim() 
       
        $out = New-Object psobject
        $out | Add-Member NoteProperty Name ($displayName)
        $out | Add-Member NoteProperty Email ($notify.useremail)
        $out | Add-Member NoteProperty byEmail ($notify.email)
        $out | Add-Member NoteProperty byTextmessage ($notify.phone)
        $out | Add-Member NoteProperty byTicket ($notify.ticket)
        if ($notify.deferTime) {
            $out | Add-Member NoteProperty Delay ($notify.deferTime)
        } else {
            $out | Add-Member NoteProperty Delay (0)
        }
        $out | Add-Member NoteProperty NotificationId ($notify.nId)
        $out | Add-Member NoteProperty Sensorhub ($sensorhubName)
        $out | Add-Member NoteProperty OCC-Connector ($connectorName)
        $out | Add-Member NoteProperty Customer ($customerName)
        $out
    }
}

function getNotificationBySensor ($sensorId, $auth) {
    $notifies = Get-SeApiAgentNotificationList -AuthToken $auth -AId $sensorId
    $sensor = get-SeSensor -SensorId $sensorId -AuthToken $auth

    foreach ($notify in $notifies) {
        $displayName = "$($notify.prename) $($notify.surname)".Trim() 
       
        $out = New-Object psobject
        $out | Add-Member NoteProperty Name ($displayName)
        $out | Add-Member NoteProperty Email ($notify.useremail)
        $out | Add-Member NoteProperty byEmail ($notify.email)
        $out | Add-Member NoteProperty byTextmessage ($notify.phone)
        $out | Add-Member NoteProperty byTicket ($notify.ticket)
        if ($notify.deferTime) {
            $out | Add-Member NoteProperty Delay ($notify.deferTime)
        } else {
            $out | Add-Member NoteProperty Delay (0)
        }
        $out | Add-Member NoteProperty NotificationId ($notify.nId)
        $out | Add-Member NoteProperty Sensor ($sensor.name)
        $out | Add-Member NoteProperty Sensorhub ($sensor.sensorhub)
        $out | Add-Member NoteProperty OCC-Connector ($sensor.'OCC-Connector')
        $out | Add-Member NoteProperty Customer ($sensor.customer)
        $out
    }

}
