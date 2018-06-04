<# 
    .SYNOPSIS
    Add a Note to all Container with the ServerName.

    .DESCRIPTION
    Add a Note to all Container with the ServerName.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

    .PARAMETER ServerName
    The Name of the Server where the note should be added to.

    .PARAMETER Message
    The Message you want to add.
    
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $ServerName,
    [Parameter(Mandatory = $True)]
    $Message
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id -and $sensorhub.Name -eq $ServerName) {

                    $note = New-SeApiContainerNote -AuthToken $AuthToken -CId $sensorhub.id -Message $message

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