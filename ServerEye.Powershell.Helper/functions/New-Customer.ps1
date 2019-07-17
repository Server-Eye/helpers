 <#
    .SYNOPSIS
    Creates a new Customer in the OCC.
    
    .DESCRIPTION
    Creates a new Customer in the OCC.
    
    .PARAMETER companyName
    The Company Name for the New Customer.

    .PARAMETER zipCode
    The Zip Code for the New Customer.

    .PARAMETER city
    The City for the New Customer.

    .PARAMETER country
    The Country for the New Customer.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    companyName
    zipCode
    city
    country
#>
function New-Customer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $companyName,
        [Parameter(Mandatory=$true)]
        $zipCode,
        [Parameter(Mandatory=$true)]
        $city,
        [Parameter(Mandatory=$true)]
        $country,
        [Parameter(Mandatory=$false)]
        $Street,
        [Parameter(Mandatory=$false)]
        $StreetNumber,
        [Parameter(Mandatory=$false)]
        $Email,
        [Parameter(Mandatory=$false)]
        $Phone,
        [Parameter(Mandatory=$false)]
        [ValidateSet('en','de')]
        $Language,
        [Parameter(Mandatory=$false)]
        $Timezone,
        [Parameter()]
        [alias("ApiKey","Session")]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
                $customer = New-SeApiCustomer -AuthToken $AuthToken -companyName $companyName -zipCode $zipCode -city $city -country $country -Street $Street -StreetNumber $StreetNumber -Email $Email -Phone $Phone -Language $Language -Timezone $Timezone
                [PSCustomObject]@{
                    Name = $customer.companyName
                    CustomerId = $customer.customer_id
                    SecretKey = $customer.secretKey
                    CustomerNumber = $customer.customerNumberExtern
                }
            }
}


