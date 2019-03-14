<#
    .SYNOPSIS
    Get a list of all customers. 
    
    .DESCRIPTION
    A list of all customers the user has been assigned to. 
    
    .PARAMETER Filter
    Filter the list to show only matching customers, wildcards can be used. Customers are filterd based on the name of the customer.

    .PARAMETER CustomerId
    Shows the specific customer with this customer Id.

    .PARAMETER All
    Shows the all customers
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer

    Name                       CustomerId                           CustomerNumber
    ----                       ----------                           --------------
    Systemmanager IT           4028e08a2e0ed329012e4ca526f705b1           75953213
    RT Privat                  aac53bb3-2733-4247-a9ff-3844c9130b6e       11710377
    SE Landheim                3a8000cc-e09c-44c1-99aa-41f85abd59a8       46570910
    Server-Eye Support         4028e08a3e65d9e5013e7a04e3ad009b           49511392
    Wortmann Demo (gesponsert) 3e2c14de-c28f-4297-826a-cc645b725be2       92131923

    .EXAMPLE 
    Get-SECustomer -CustomerId "4028e08a2e0ed329012e4ca526f705b1"

    Name             CustomerId                       CustomerNumber
    ----             ----------                       --------------
    Systemmanager IT 4028e08a2e0ed329012e4ca526f705b1       75953213

    .EXAMPLE 
    Get-SECustomer -Filter "Systemmanager*"

    Name             CustomerId                       CustomerNumber
    ----             ----------                       --------------
    Systemmanager IT 4028e08a2e0ed329012e4ca526f705b1       75953213

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-Customer {
    [CmdletBinding(DefaultParameterSetName = 'byFilter')]
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = 'byFilter', Position = 0)]
        [string]$Filter,
        [Parameter(Mandatory = $false, ParameterSetName = 'byCustomerId')]
        [string]$CustomerId,
        [Parameter(Mandatory = $false, ParameterSetName = 'byFilter')]
        [switch]$all,
        [Parameter(Mandatory = $false, ParameterSetName = 'byFilter')]
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false, ParameterSetName = 'byCustomerId')]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        if ($all.IsPresent -eq $true) {
            $customers = Get-SeApiCustomerList -AuthToken $AuthToken
            foreach ($customer in $customers) {
                [PSCustomObject]@{
                    Name           = $customer.companyName
                    CustomerId     = $customer.cId
                    CustomerNumber = $customer.customerNumberExtern
                }
            }
        }

        elseif ($CustomerId) {

            $customer = Get-SeApiCustomer -CId $CustomerId -AuthToken $AuthToken
            [PSCustomObject]@{
                Name           = $customer.companyName
                CustomerId     = $customer.cId
                CustomerNumber = $customer.customerNumberExtern
            }

        }
        else {
            $customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
            foreach ($customer in $customers) {
    
                if ((-not $Filter) -or ($customer.name -like $Filter)) {
                    [PSCustomObject]@{
                        Name           = $customer.name
                        CustomerId     = $customer.id
                        CustomerNumber = $customer.customerNumberExtern
                    }
                }
            }
        }
    }
}

