<#
    .SYNOPSIS
    Removes a User as Manager of a Customer. 

    .PARAMETER CustomerId
    The ID of the Customer the Manager should be removed from.

    .PARAMETER Userid
    The ID of User that should be removed as a Manager.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Remove-Manager {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $CustomerId,
        [Parameter(Mandatory=$true)]
        $Userid
    )

    Begin {
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }

    Process {  
        Remove-SeApiCustomerManager -AuthToken $AuthToken -CId $CustomerId -uid $Userid
        $User = Get-SeApiUser -AuthToken $AuthToken -uid $Userid
        $displayname = ("$($user.prename) $($user.surname)".Trim())
        $Customer = Get-SeApiCustomer -AuthToken $AuthToken -CId $CustomerId
        Write-Host "Manager $Displayname was Removed from"$Customer.companyName
}

    End {

    }
}