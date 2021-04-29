<#
    .SYNOPSIS
    Get a list of all Customer Properties. 
    
    .DESCRIPTION
    Get a list of all Customer Properties. 

    .PARAMETER Customerid
    Id of the Customer the Properties should be shown.
        
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer -Filter "Systemmanager*" | Get-SECustomerProperties

    Name             CustomerId                       Properties
    ----             ----------                       ----------
    Systemmanager IT 4028e08a2e0ed329012e4ca526f705b1 @{Key=Value; Benutzerdefiniertes=Feld}

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-CustomerProperties {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
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
        [PSCustomObject]@{
            Name       = $customer.companyName
            CustomerId = $customer.cid
            Properties = $customer.Properties
        }     
    }
}