<# 
    .SYNOPSIS
    Add a Note to all Container for this Customer.

    .DESCRIPTION
    Add a Note to all Container for this Customer.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

    .PARAMETER CustomerID
    The ID of Customer the note should be added to.

    .PARAMETER Message
    The Message you want to add.
    
#>
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $customerID,
    [Parameter(Mandatory = $True)]
    $Message
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

    If ($customer.id -eq $customerID) {

        $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

        foreach ($container in $containers) {

            if ($container.subtype -eq "0") {

                foreach ($sensorhub in $containers) {

                    if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

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
}
