[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    [string]$userID,
    [Parameter(Mandatory = $True)]
    [string]$AgentType,
    [switch]$email,
    [switch]$Phone,
    [switch]$ticket,
    [string]$deferId = ""
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                    foreach ($agent in $agents) {
                                                                                            
                        if ($agent.subtype -eq $AgentType) {

                            $notifications = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $agent.id

                            if ($notifications) {

                                foreach ($notification in $notifications) {

                                    if ($notification.userId -eq $userID) {
                                        $currentnotifcations = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -NId $notification.nId -Email $email.IsPresent -Phone $Phone.IsPresent -Ticket $ticket.IsPresent

                                        if ($currentnotifcations) {

                                            foreach ($currentnotifcation in $currentnotifcations) {
                                                $currentnotifcation = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $currentnotifcation.aId | Where-Object {$_.Nid -eq $currentnotifcation.nId} 
                                                
                                                [PSCustomObject]@{
                                                    Customer     = $customer.name
                                                    Network      = $container.name
                                                    Server       = $sensorhub.name
                                                    Agent        = $agent.name
                                                    Notification = if ($currentnotifcation.isGroup -eq $true) {
                                                        $currentnotifcation.surname
                                                    }
                                                    else {
                                                        "$($currentnotifcation.prename) $($currentnotifcation.surname)".Trim() 
                                                    }
                                                    EMail        = $currentnotifcation.email
                                                    Phone        = $currentnotifcation.phone
                                                    Ticket       = $currentnotifcation.ticket
                                                    Defer        = if ($deferId -ne "") {
                                                        $snn = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -NId $nnotification.nId -DeferId $deferId 
                                                        $gnn = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $Snn.aId | Where-Object {$_.Nid -eq $nnotification.nId}
                                                        [PSCustomObject]@{
                                                            Defertime = $gnn.deferTime
                                                            Defername = $gnn.deferName
                                                        }   
                                                    }
                                                    else {
                                                        "No Deferid was set."
                                                    }
                                                    State        = "Notification was present, maybe changed."
                                                }
                                            }
                                        }
                                                     
                                    }
                                }
                            }
                            else {

                                $nnotifications = New-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -UserId $userID -Email $email.IsPresent -Phone $Phone.IsPresent -Ticket $ticket.IsPresent

                                if ($nnotifications) {
                                    foreach ($nnotification in $nnotifications) {
                                        $nnotification = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $nnotification.aId | Where-Object {$_.Nid -eq $nnotification.nId}
                                        [PSCustomObject]@{
                                            Customer     = $customer.name
                                            Network      = $container.name
                                            Server       = $sensorhub.name
                                            Agent        = $agent.name
                                            Notification = if ($nnotification.isGroup -eq $true) {
                                                $nnotification.surname
                                            }
                                            else {
                                                $displayName = "$($nnotification.prename) $($nnotification.surname)".Trim() 
                                                $displayName
                                            }
                                            EMail        = $nnotification.email
                                            Phone        = $nnotification.phone
                                            Ticket       = $nnotification.ticket
                                            Defer        = if ($deferId -ne "") {
                                                $snn = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -NId $nnotification.nId -DeferId $deferId 
                                                $gnn = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $Snn.aId | Where-Object {$_.Nid -eq $nnotification.nId}
                                                [PSCustomObject]@{
                                                    Defertime = $gnn.deferTime
                                                    Defername = $gnn.deferName
                                                }
                                            }
                                            else {
                                                "No Deferid was set."
                                            }
                                            State        = "New"
                                        }           
                                    }
                                }                         
                            }                                                         
                        }                 
                    }
                }
            }
        }
    }
}