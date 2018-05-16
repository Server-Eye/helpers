[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
    
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken
$Sensortype = "72AC0BFD-0B0C-450C-92EB-354334B4DAAB"
#$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
                                       
                        foreach ($agent in $agents) {
                        
                        if ($agent.subtype -like $Sensortype){
                            $version = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $agent.id -IncludeRawData "true"
                            [PSCustomObject]@{

                            Kunde = $customer.name
                            Netzwerk = $container.name
                            System = $sensorhub.name
                            Sensor = $agent.name
                            Version = $version.raw.data.productVersion.version 
                            }
                            }
                        }
                    }
                }
            }
        }
    }
$result

