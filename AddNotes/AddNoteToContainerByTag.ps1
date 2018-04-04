[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    $tag,
    $message=(Read-Host "Wie lautet die gewünschte Notiz")
)

$tag = "test12"
$AuthToken = Test-SEAuth -AuthToken $AuthToken

$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $tags = Get-SeApiContainerTagList -AuthToken $AuthToken -CId $sensorhub.id 
                          if ($tags.name -eq $tag) {
                            $note = New-SeApiContainerNote -AuthToken $AuthToken -CId $sensorhub.id -Message $message
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty System ($sensorhub.name)
                            $out | Add-Member NoteProperty Notiz ($note.message)
                            $result += $out
                            }
                        }
                    }
                }
            }
        }
$result