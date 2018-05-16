<#
    .SYNOPSIS
    Get a list of all manager of a customers. 
    
    .DESCRIPTION
    A list of all manager of a customers the user has been assigned to. 
    
    .PARAMETER CustomerId
    Shows the manager of this customer Id.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-CustomerManager {
    [CmdletBinding(DefaultParameterSetName='byCustomerId')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="byCustomerId")]
        $CustomerId,
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process{

            $Customer = Get-SeApiCustomer -CId $CustomerId -AuthToken $AuthToken
            $managers = Get-SeApiCustomerManagerList -CId $CustomerId -AuthToken $AuthToken

                foreach ($manager in $managers){
                    [PSCustomObject]@{
                        Name = $Customer.companyName
                        CustomerId = $Customer.cId
                        CustomerNumber = $Customer.customerNumberExtern
                        User = $manager.prename + " " +  $manager.surname
                        Mail = $manager.email
                    }
                }
    }
}
