 <#
    .SYNOPSIS
    Get a list of all Customer Properties. 
    
    .DESCRIPTION
    Get a list of all Customer Properties. 

    .PARAMETER Customerid
    Id of the Customer the Properties should be shown.
        
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-CustomerProperties{
    [CmdletBinding(DefaultParameterSetName='None')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $CustomerId,
        $AuthToken
    )
    Begin{
        $AuthToken = Test-seAuth -AuthToken $AuthToken
    }
    
    Process {
            if (-not $customerid){
                Read-Host 
            }
            $customer = Get-SeApiCustomer -AuthToken $authtoken -CId $CustomerId
                [PSCustomObject]@{
                        Name = $customer.companyName
                        CustomerId = $customer.cid
                        Properties = $customer.Properties
                }     
    }
}