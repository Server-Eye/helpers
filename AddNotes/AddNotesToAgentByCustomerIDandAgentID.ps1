<# 
    .SYNOPSIS
    Add a Note to an Agent based on the Customer and the AgentType.

    .DESCRIPTION
    Add a Note to an Agent based on the Customer and the AgentType, addes the Note to specified Agents of this Customer.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

    .PARAMETER CustomerID
    The ID of Customer the note should be added to.

    .PARAMETER AgentType
    The ID of AgentType the note should be added to.

    .PARAMETER Message
    The Message you want to add.
    
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $CustomersID,
    [Parameter(Mandatory = $True)]
    $AgentType,
    [Parameter(Mandatory = $True)]
    $Message
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken


$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {

    if ($customer.id -eq $customersID) {

        $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

        foreach ($container in $containers) {

            if ($container.subtype -eq "0") {

                foreach ($sensorhub in $containers) {

                    if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    
                        $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
                                        
                        foreach ($agent in $agents) {

                            if ($agent.subtype -eq $AgentType) {

                                $note = New-SeApiAgentNote -AuthToken $AuthToken -AId $agent.id -Message $message

                                [PSCustomObject]@{
                                    Customer = ($customer.name)
                                    Network  = ($container.name)
                                    System   = ($sensorhub.name)
                                    Agent    = ($agent.name)
                                    Note     = ($note.message)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}