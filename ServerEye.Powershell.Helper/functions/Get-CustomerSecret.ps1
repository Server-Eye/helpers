<#
    .SYNOPSIS
    Get a list with the secret Key.
    
    .DESCRIPTION
    Get a list with the secret Key for a customer, nessesary for the installation of Server-Eye via the PowerShell.

    .PARAMETER CustomerId
    Shows the specific customer with this customer Id.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomerSecret -CustomerId "4028e08a2e0ed329012e4ca526f705b1"

    Name             CustomerId                       CustomerNumber secretKey
    ----             ----------                       -------------- ---------
    Systemmanager IT 4028e08a2e0ed329012e4ca526f705b1       75953213 *********************************

    .LINK 
    https://api.server-eye.de/docs/2/
        
#>
function Get-CustomerSecret {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
        [string]$CustomerId,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $Customer = Get-SECustomer -CustomerId $CustomerId -AuthToken $AuthToken
        $Secret = Get-SeApiCustomerSecret -cid $CustomerId -AuthToken $AuthToken
        [PSCustomObject]@{
            Name           = $customer.Name
            CustomerId     = $customer.CustomerId
            CustomerNumber = $customer.CustomerNumber
            secretKey      = $Secret.secretKey
        }
    }
}

