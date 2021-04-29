<#
    .SYNOPSIS
    Get notifications for a sensor. 
    
    .DESCRIPTION
    This will list all notifications for a sensor.
    
    .PARAMETER SensorId
    The id of the sensor for which the notifications should be listed.

    .PARAMETER Filter
    You can filter the notification based on the FullName (Prename and Surname) or the Email of the User.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE
    Get-SENotification -SensorId "12345-6789-ABCDE"

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
    [CmdletBinding(DefaultParameterSetName = 'ofSensor')]
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = "ofSensor", Position = 0)]
        [Parameter(Mandatory = $false, ParameterSetName = "ofSensorhub", Position = 0)]
        [string]$Filter,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true, ParameterSetName = 'ofSensor')]
        $SensorId,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true, ParameterSetName = 'ofSensorhub')]
        [Alias("ConnectorID")]
        $SensorhubId,
        [Parameter(Mandatory = $false, ParameterSetName = 'ofSensorhub')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ofSensor')]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($SensorId) {
            getNotificationBySensor -sensorId $SensorId -auth $AuthToken
        }
        elseif ($SensorhubId) {
            getNotificationOfContainer -containerID $SensorhubId -auth $AuthToken
        }
        else {
            Write-Error "Unsupported input"
        }
        
    }

    End {

    }
}

function getNotificationOfContainer ($containerID, $auth) {
    $notifies = Get-SeApiContainerNotificationList -AuthToken $auth -CId $containerId
    $Container = Get-CachedContainer -ContainerID $ContainerID -AuthToken $Auth
    $customer = Get-CachedCustomer -customerid $container.customerid -authtoken $Auth
    
    if ($container.type -eq "0") {
        foreach ($notify in $notifies) {
            $displayName = "$($notify.prename) $($notify.surname)".Trim() 
            if ((-not $filter) -or ($notify.useremail -like $filter) -or $displayName -like $filter) {
                formatMACNotification -notify $notify -container $container -displayname $displayName  -auth $AuthToken
            }
        }

    }
    else {
        $MAC = Get-CachedContainer -ContainerID $Container.parentId -AuthToken $AuthToken
        foreach ($notify in $notifies) {
            $displayName = "$($notify.prename) $($notify.surname)".Trim() 
            if ((-not $filter) -or ($notify.useremail -like $filter) -or $displayName -like $filter) {
                formatCCNotification -notify $notify -container $container -mac $mac -displayname $displayName -auth $AuthToken
            }
        }
    }
}

function getNotificationBySensor ($sensorId, $auth) {
    $notifies = Get-SeApiAgentNotificationList -AuthToken $auth -AId $sensorId
    $sensor = get-SeSensor -SensorId $sensorId -AuthToken $auth

    foreach ($notify in $notifies) {
        $displayName = "$($notify.prename) $($notify.surname)".Trim() 
        if ((-not $filter) -or ($notify.useremail -like $filter) -or $displayName -like $filter) {
            formatSensorNotification -notify $notify -auth $auth -sensor $sensor
        }
    }

}
function formatSensorNotification($notify, $auth, $sensor) {
    [PSCustomObject]@{
        Name            = $displayName
        Email           = $notify.useremail
        byEmail         = $notify.email
        byTextmessage   = $notify.phone
        byTicket        = $notify.ticket
        DelayName       = if ($notify.deferName) {
            $notify.deferName
        }
        else {
            ""
        }
        Delay           = if ($notify.deferTime) {
            $notify.deferTime
        }
        else {
            "0"
        }
        DelayID         = if ($notify.deferId) {
            $notify.deferId
        }
        else {
            ""
        }
        NotificationId  = $notify.nId
        Sensor          = $sensor.name
        SensorID        = $sensor.SensorId
        Sensorhub       = $sensor.sensorhub
        'OCC-Connector' = $sensor.'OCC-Connector'
        Customer        = $sensor.customer
    }
}

function formatMACNotification($notify, $container, $displayName, $auth) {
    [PSCustomObject]@{
        Name            = $displayName
        Email           = $notify.useremail
        byEmail         = $notify.email
        byTextmessage   = $notify.phone
        byTicket        = $notify.ticket
        DelayName       = if ($notify.deferName) {
            $notify.deferName
        }
        else {
            ""
        }
        Delay           = if ($notify.deferTime) {
            $notify.deferTime
        }
        else {
            "0"
        }
        DelayID         = if ($notify.deferId) {
            $notify.deferId
        }
        else {
            ""
        }
        NotificationId  = $notify.nId
        ConnectorId     = $container.cid
        'OCC-Connector' = $container.name
        Customer        = $customer.companyname
    }
}

function formatCCNotification($notify, $container, $mac, $displayName, $auth) {
    [PSCustomObject]@{
        Name            = $displayName
        Email           = $notify.useremail
        byEmail         = $notify.email
        byTextmessage   = $notify.phone
        byTicket        = $notify.ticket
        DelayName       = if ($notify.deferName) {
            $notify.deferName
        }
        else {
            ""
        }
        Delay           = if ($notify.deferTime) {
            $notify.deferTime
        }
        else {
            "0"
        }
        DelayID         = if ($notify.deferId) {
            $notify.deferId
        }
        else {
            ""
        }
        NotificationId  = $notify.nId
        Sensorhub       = $container.name
        SensorhubId     = $container.cid
        'OCC-Connector' = $mac.name
        Customer        = $customer.companyName
    }
}