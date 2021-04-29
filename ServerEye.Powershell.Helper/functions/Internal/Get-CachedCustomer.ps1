function Get-CachedCustomer {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        $CustomerId,
        [parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        if (!$Global:ServerEyeCustomer) {
            $Global:ServerEyeCustomer = @()
        }
    }

    Process {
        if ($global:ServerEyeCustomer.cid -contains $CustomerId) {
            Write-Debug "Customer Caching"
            $Customer = $global:ServerEyeCustomer | Where-Object { $_.cid -eq $CustomerId }

        }
        else {
            Write-Debug "Customer API Call"
            $Customer = Get-SeApiCustomer -cid $CustomerId -AuthToken $AuthToken
            $global:ServerEyeCustomer += $customer
        }
        return $customer
    }
    end {

    }
}
