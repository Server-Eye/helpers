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
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-Customer {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName='byFilter',Position=0)]
        [string]$Filter,
        [Parameter(Mandatory=$false,ParameterSetName='byCustomerId')]
        [string]$CustomerId,
        [Parameter(Mandatory=$false,ParameterSetName='byFilter')]
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,ParameterSetName='byCustomerId')]
        [alias("ApiKey","Session")]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        if ($CustomerId) {

            $customer = Get-SeApiCustomer -CId $CustomerId -AuthToken $AuthToken
            [PSCustomObject]@{
                Name = $customer.companyName
                CustomerId = $customer.cId
                CustomerNumber = $customer.customerNumberExtern
            }

        } else {
            $customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
            foreach ($customer in $customers) {
    
                if ((-not $Filter) -or ($customer.name -like $Filter)) {
                    [PSCustomObject]@{
                        Name = $customer.name
                        CustomerId = $customer.id
                        CustomerNumber = $customer.customerNumberExtern
                    }
                }
            }
        }
    }
}

