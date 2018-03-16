[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [string]$userID,
    [string]$CustomerID,
    [bool]$email=$false,
    [bool]$Phone=$false,
    [bool]$ticket=$false,
    [string]$deferId=$null
)

$UserID = "e35002c3-4d90-45b0-93a9-6668add6aae1"
$AuthToken = "dfd844d5-be47-4265-ab62-fef204988baa"
$CustomerID = "aac53bb3-2733-4247-a9ff-3844c9130b6e"

$AuthToken = Test-SEAuth -AuthToken $AuthToken
$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {
    if($customer.id -eq $CustomerID){
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                     foreach ($agent in $agents) {
                                                                                            
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
                                $out | Add-Member NoteProperty Verzoegert ($currentnotifcation.deferTime)
                                $out | Add-Member NoteProperty Zustand ("Schon vorhanden, gegebenfalls verändert!")
                                $result += $out 
                                }
                            }
                                                     
                         }
                         }
                         }
                        else {

                        $nnotifications = New-SeApiAgentNotification -AuthToken $AuthToken -AId $agent.id -UserId $userID -Email $email -Phone $Phone -Ticket $ticket <#-DeferId $deferId#>
                       
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
                                $out | Add-Member NoteProperty Verzoegert ($nnotification.deferTime)
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
$result | FT

