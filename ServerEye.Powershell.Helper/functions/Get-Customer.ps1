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
    [OutputType("ServerEye.Customer")]
    [CmdletBinding(DefaultParameterSetName = 'byFilter')]
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = 'byFilter', Position = 0)]
        [string]$Filter,
        [Parameter(Mandatory = $false, ParameterSetName = 'byCustomerId')]
        [string]$CustomerId,
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [switch]$all,
        [Parameter(Mandatory = $false, ParameterSetName = 'byFilter')]
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false, ParameterSetName = 'byCustomerId')]
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        if (!(Get-Typedata "ServerEye.Customer")) {
            $SECustomerTypeData = @{
                TypeName                  = "ServerEye.Customer"
                DefaultDisplayPropertySet = "Name", "CustomerId", "CustomerNumber"
    
            }
            Update-TypeData @SECustomerTypeData
        }

    }

    Process {
        if ($all.IsPresent -eq $true) {
            $Listcustomers = Get-SeApiCustomerList -AuthToken $AuthToken
            foreach ($ListCustomer in $ListCustomers) {
                
                [PSCustomObject]@{
                    PSTypeName     = "ServerEye.Customer"
                    Name           = $ListCustomer.companyName
                    CustomerId     = $ListCustomer.cId
                    CustomerNumber = $ListCustomer.customerNumberExtern
                    Street         = $ListCustomer.street
                    StreetNumber   = $ListCustomer.streetNumber
                    ZipCode        = $ListCustomer.zipCode
                    City           = $ListCustomer.city
                    country        = $Listcustomer.country
                }
            }
        }
        elseif ($CustomerId) {
            Format-Customer -CustomerId $CustomerId -AuthToken $AuthToken
        }
        else {
            $Nodecustomers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
            foreach ($Nodecustomer in $Nodecustomers) {
                if ((-not $Filter) -or ($Nodecustomer.name -like $Filter)) {
                Format-Customer -CustomerId $Nodecustomer.id -AuthToken $AuthToken
                }
            }
        }
    }
}

function Format-Customer {
    param (
        $CustomerId,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

        $customer = Get-SeApiCustomer -CId $CustomerId -AuthToken $AuthToken
        Write-Debug $customer
        [PSCustomObject]@{
        PSTypeName             = "ServerEye.Customer"
        Name                   = $customer.companyName
        CustomerId             = $customer.cId
        CustomerNumber         = $customer.customerNumberExtern
        customerNumberIntern   = $customer.customerNumberIntern
        Street                 = $customer.street
        StreetNumber           = $customer.streetNumber
        ZipCode                = $customer.zipCode
        City                   = $customer.city
        country                = $customer.country
        email                  = $customer.email
        phone                  = $customer.phone
        distributor            = $customer.distributor
        distributorInformation = $customer.distributorInformation
        customData             = $customer.customData
        properties             = $customer.properties
        licenses               = $customer.licenses
    }

}