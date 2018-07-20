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

# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            $containertags = Get-SeApiContainerTagList -AuthToken $AuthToken -CId $container.id

                    if ($conatinertag.name -ne $tag) {
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

                            if ($sensorhubtags.name -ne $tag) {
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


                                    if ($agenttag.name -ne $tag) {

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