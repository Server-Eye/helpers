<#
    .SYNOPSIS
    Get a list of all customers. 
    
    .DESCRIPTION
    A list of all customers the user has been assigned to. 
    To see all customers use Get-SeApiCustomerList.
    
    .PARAMETER Filter
    Filter the list to show only matching customers. Customers are filterd based on the name of the customer.

    .PARAMETER CustomerId
    Shows the specific customer with this customer Id.

    .PARAMETER All
    Shows the specific customer with this customer Id.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-CustomerSecret {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory = $true)]
        [string]$CustomerId,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $Customer = Get-SECustomer -CustomerId $CustomerId
        $Secret = Get-SeApiCustomerSecret -cid $CustomerId -AuthToken $AuthToken
        [PSCustomObject]@{
            Name           = $customer.Name
            CustomerId     = $customer.CustomerId
            CustomerNumber = $customer.CustomerNumber
            secretKey = $Secret.secretKey
        }
    }
}

