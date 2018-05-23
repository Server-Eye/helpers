[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    # Tag to filter by
    [Parameter(Mandatory=$true)]
    [string]
    $Tag
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            $containertags = Get-SeApiContainerTagList -AuthToken $AuthToken -CId $container.id

                    if ($containertags.name -eq $tag) {
                        [PSCustomObject]@{
                        Customer = $customer.name
                        Network = $container.name
                        System = ""
                        Agent = "" 
                        Tag = $containertags.Name
                        }
                    }

            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $sensorhubtags = Get-SeApiContainerTagList -AuthToken $AuthToken -CId $sensorhub.id

                            if ($sensorhubtags.name -eq $tag) {
                                [PSCustomObject]@{
                                Customer = $customer.name
                                Network = $container.name
                                System = $sensorhub.name
                                Agent = ""
                                Tag = $sensorhubtags.Name
                                }
                            }

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
    
                        foreach ($agent in $agents) {
                            $agenttags = Get-SeApiAgentTagList -AuthToken $AuthToken -aid $agent.id

                                    if ($agenttags.name -eq $tag) {

                                        [PSCustomObject]@{
                                        Customer = $customer.name
                                        Network = $container.name
                                        System = $sensorhub.name
                                        Agent = $agent.name
                                        Tag = $agenttags.name
                                        }
                                    }
                        }
                    }
                }
            }
        }
    }