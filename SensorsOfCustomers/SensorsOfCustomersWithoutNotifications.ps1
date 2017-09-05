[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
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
                        $notifications = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $agent.id

                        if (!$notifications) {
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
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