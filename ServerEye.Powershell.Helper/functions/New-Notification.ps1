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
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [Parameter(Mandatory=$false)]
        $UserId,
        [Parameter(Mandatory=$false)]
        $SendEmail,
        [Parameter(Mandatory=$false)]
        $SendTextmessage,
        [Parameter(Mandatory=$false)]
        $SendTicket,
        [Parameter(Mandatory=$false)]
        $DeferId="",
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }

    Process {
        $notify = New-SeApiAgentNotification -AuthToken $AuthToken -AId $SensorId -UserId $UserId -Email $SendEmail -Phone $SendTextmessage -Ticket $SendTicket

        $displayName = "$($notify.prename) $($notify.surname)".Trim() 
        
        $sensor = get-SeSensor -SensorId $notify.aId -AuthToken $AuthToken
        
        $out = New-Object psobject
        $out | Add-Member NoteProperty Name ($displayName)
        $out | Add-Member NoteProperty Email ($notify.useremail)
        $out | Add-Member NoteProperty byEmail ($notify.email)
        $out | Add-Member NoteProperty byTextmessage ($notify.phone)
        $out | Add-Member NoteProperty byTicket ($notify.ticket)
        if ($deferId -ne ""){
            $sn = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $SensorId -NId $notify.nId -DeferId $deferId 
            $gn = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $sn.aId | Where-Object {$_.Nid -eq $notify.nId}
            $out | Add-Member NoteProperty Verzoegertszeit ($gn.deferTime)
            $out | Add-Member NoteProperty Verzoegertsname ($gn.deferName)
            }
        $out | Add-Member NoteProperty NotificationId ($notify.nId)
        $out | Add-Member NoteProperty Sensor ($sensor.name)
        $out | Add-Member NoteProperty Sensorhub ($sensor.sensorhub)
        $out | Add-Member NoteProperty OCC-Connector ($sensor.'OCC-Connector')
        $out | Add-Member NoteProperty Customer ($sensor.customer)
        $out
    }

    End {

    }
}
