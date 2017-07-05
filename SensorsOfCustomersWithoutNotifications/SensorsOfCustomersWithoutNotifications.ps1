[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
)

$result = @()

$customers = Get-MyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-CustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    $agents = Get-ContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                    foreach ($agent in $agents) {
                        $notifications = Get-AgentNotificationList -AuthToken $AuthToken -AId $agent.id

                        if (!$notificationss) {
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($customer.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $result += $out
                        }
                    }
                }
            }
        }
    }
}
$result