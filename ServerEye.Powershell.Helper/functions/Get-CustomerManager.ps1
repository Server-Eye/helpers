<#
    .SYNOPSIS
    Get a list of all manager of a customers. 
    
    .DESCRIPTION
    A list of all manager of a customers the user has been assigned to. 
    
    .PARAMETER CustomerId
    Shows the manager of this customer.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer -Filter "Systemmanager*" | Get-SECustomerManager

    CustomerName   : Systemmanager IT
    CustomerId     : 4028e08a2e0ed329012e4ca526f705b1
    CustomerNumber : 75953213
    User           : Demo Demo
    Mail           : demo@server-eye.de

    .LINK 
    https://api.server-eye.de/docs/2/

    
#>
function Get-CustomerManager {
    [CmdletBinding(DefaultParameterSetName = 'byCustomerId')]
    Param(
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "byCustomerId")]
        $CustomerId,
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($global:ServerEyeCustomer.cid -contains $CustomerId) {
            Write-Debug "Caching"
            $Customer = $global:ServerEyeCustomer | Where-Object {$_.cid -eq $CustomerId}
        }else {
            Write-Debug "API Call"
            $Customer = Get-SeApiCustomer -CId $CustomerId -AuthToken $AuthToken
            $global:ServerEyeCustomer = $Customer
        }
        $managers = Get-SeApiCustomerManagerList -CId $Customer.cID -AuthToken $AuthToken

        foreach ($manager in $managers) {
            [PSCustomObject]@{
                CustomerName   = $Customer.companyName
                CustomerId     = $Customer.cId
                CustomerNumber = $Customer.customerNumberExtern
                User           = $manager.prename + " " + $manager.surname
                Mail           = $manager.email
            }
        }
    }
}
