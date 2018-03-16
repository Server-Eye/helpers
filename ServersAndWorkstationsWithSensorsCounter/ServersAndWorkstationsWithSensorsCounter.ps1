[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
)


$AuthToken = Test-SEAuth -AuthToken $AuthToken

$result = @()

$occ = 0
$cc = 0
$a = 0

$out = New-Object psobject

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {
            $occ++
            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
 
                    $cc++
                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
                                       
                    foreach ($agent in $agents) {
                        $a++
                         }
                    }
                }
            }
        }
    }

$out | Add-Member NoteProperty OCC-Connectoren ($occ)
$out | Add-Member NoteProperty Sensorhubs ($cc)
$out | Add-Member NoteProperty Sensoren ($a)
$result += $out
$result
