<#
    .SYNOPSIS
    Create a new notification. 

    .PARAMETER CustomerId
    The ID of the Customer the Manager should be added to.

    .PARAMETER email
    The Email of User that should become an Manager.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Set-Manager {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $AuthToken,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $CustomerId,
        [Parameter(Mandatory=$true)]
        $email
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        try{
            Set-SeApiCustomerManager -AuthToken $AuthToken -CId $CustomerId -Email $email -ErrorAction Stop -ErrorVariable x
            Write-Host "Manager was set"
        }
            Catch{
                if($x[0].ErrorRecord.ErrorDetails.Message -match ('error":"ER_DUP_ENTRY: Duplicate entry')  ){
                    Write-host "The user is already Manager."
                }
            }        
    }

    End {

    }
}
