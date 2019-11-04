<#
    .SYNOPSIS
    Updates a property of a customer.
    
    .DESCRIPTION
    Updates a property of a customer.
    
    .PARAMETER CustomerID
    The id of the Customer.

    .PARAMETER Key
    The name of your custom property.

    .PARAMETER Value
    The value of the property.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    New-CustomerProperty -CustomerID "11113333-8888-aaaa-bbbb-cccccustomer" -Key "Test" -Value "1234"

    Name                       CustomerId                           Keyname Value
    ----                       ----------                           ------- -----
    Wortmann Demo (gesponsert) 11113333-8888-aaaa-bbbb-cccccustomer Test    1234 

    .LINK 
    https://api.server-eye.de/docs/2/#/customer/post_customer_property

#>
function New-CustomerProperty {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $CustomerID,
        [Parameter(Mandatory = $true)]
        $Key,
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter()]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $Property = New-SeApiCustomerProperty -AuthToken $AuthToken -cId $CustomerID -Key $Key -Value $Value
        $customer = Get-SECustomer -CustomerId $CustomerID          
        [PSCustomObject]@{
            Name = $customer.Name
            CustomerId = $customer.CustomerId
            Keyname = (Get-Member -InputObject $Property | Where-Object { $_.MemberType -ne "Method" }).Name
            Value = $Property.((Get-Member -InputObject $Property | Where-Object { $_.MemberType -ne "Method" }).Name)
        }
    }
}


