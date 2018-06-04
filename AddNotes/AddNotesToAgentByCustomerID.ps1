 <# 
    .SYNOPSIS
    Add a Note to an Agent based on the Customer.

    .DESCRIPTION
    Add a Note to an Agent based on the Customer, addes the Note to all Agents of this Customer.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

    .PARAMETER CustomerID
    The ID of Customer the note should be added to.

    .PARAMETER Message
    The Message you want to add.
    
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [Parameter(Mandatory=$True)]
    $CustomerID,
    [Parameter(Mandatory=$True)]
    $Message
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {

    if($customer.id -eq $customerID){

        $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

            foreach ($container in $containers) {

                if ($container.subtype -eq "0") {

                    foreach ($sensorhub in $containers) {

                        if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    
                            $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
                                        
                                foreach ($agent in $agents) {

                                    if ($agent) {

                                        $note = New-SeApiAgentNote -AuthToken $AuthToken -AId $agent.id -Message $message

                                            [PSCustomObject]@{
                                                Customer =($customer.name)
                                                Network = ($container.name)
                                                System = ($sensorhub.name)
                                                Agent = ($agent.name)
                                                Note = ($note.message)
                                            }
                                    }        
                                }
                        }
                    }
                }
            }
    }
}