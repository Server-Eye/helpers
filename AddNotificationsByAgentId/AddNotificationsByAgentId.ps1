[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [string]$userID,
    [string]$SensorType,
    [switch]$email,
    [switch]$Phone,
    [switch]$ticket,
    [string]$deferId=""
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken
$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                     foreach ($agent in $agents) {
                                                                                            
                        if ($agent.subtype -eq $SensorType) {

                        $notifications = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $agent.id

                        if ($notifications){

                          foreach ($notification in $notifications) {

                            if ($notification.userId -eq $userID) {
                                $currentnotifcations = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -NId $notification.nId -Email $email -Phone $Phone -Ticket $ticket -DeferId $deferId

                            if ($currentnotifcations) {

                               foreach ($currentnotifcation in $currentnotifcations) {
                                $currentnotifcation = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $currentnotifcation.aId | where {$_.Nid -eq $currentnotifcation.nId}     
                                $out = New-Object psobject
                                $out | Add-Member NoteProperty Kunde ($customer.name)
                                $out | Add-Member NoteProperty Netzwerk ($container.name)
                                $out | Add-Member NoteProperty Server ($sensorhub.name)
                                $out | Add-Member NoteProperty Sensor ($agent.name)
                                if ($currentnotifcation.isGroup -eq $true) {
                                    $out | Add-Member NoteProperty Benachrichtigung ($currentnotifcation.surname)
                                } 
                                else {
                                    $out | Add-Member NoteProperty Benachrichtigung ($currentnotifcation.useremail)
                                }
                                $out | Add-Member NoteProperty EMail ($currentnotifcation.email)
                                $out | Add-Member NoteProperty SMS ($currentnotifcation.phone)
                                $out | Add-Member NoteProperty Tanss ($currentnotifcation.ticket)
                                $out | Add-Member NoteProperty verzögerungszeit ($currentnotifcation.deferTime)
                                $out | Add-Member NoteProperty verzögerungszeitname ($currentnotifcation.deferName)
                                $out | Add-Member NoteProperty Zustand ("Schon vorhanden, gegebenfalls verändert!")
                                $result += $out 
                                }
                            }
                                                     
                         }
                         }
                         }
                        else {

                        $nnotifications = New-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -UserId $userID -Email $email -Phone $Phone -Ticket $ticket

                        if ($nnotifications) {
                               foreach ($nnotification in $nnotifications) {
                               $nnotification = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $nnotification.aId | where {$_.Nid -eq $nnotification.nId}

                                $out = New-Object psobject
                                $out | Add-Member NoteProperty Kunde ($customer.name)
                                $out | Add-Member NoteProperty Netzwerk ($container.name)
                                $out | Add-Member NoteProperty Server ($sensorhub.name)
                                $out | Add-Member NoteProperty Sensor ($agent.name)
                                if ($nnotification.isGroup -eq $true) {
                                    $out | Add-Member NoteProperty Benachrichtigung ($nnotification.surname)
                                } 
                                else {
                                    $out | Add-Member NoteProperty Benachrichtigung ($nnotification.useremail)
                                }
                                $out | Add-Member NoteProperty EMail ($nnotification.email)
                                $out | Add-Member NoteProperty SMS ($nnotification.phone)
                                $out | Add-Member NoteProperty Tanss ($nnotification.ticket)
                                if ($deferId -ne ""){
                                $snn = Set-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -NId $nnotification.nId -DeferId $deferId 
                                $gnn = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $Snn.aId | where {$_.Nid -eq $nnotification.nId}
                                $out | Add-Member NoteProperty Verzoegertszeit ($gnn.deferTime)
                                $out | Add-Member NoteProperty Verzoegertsname ($gnn.deferName)
                                }
                                $out | Add-Member NoteProperty Zustand ("Neu")
                                $result += $out
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
$result

