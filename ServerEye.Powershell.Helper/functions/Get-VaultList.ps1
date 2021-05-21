<#
    .SYNOPSIS
    Get Customer Vaults
    
    .DESCRIPTION
    Get Customer Vaults

    .PARAMETER CustomerId
    Shows the specific Vaults form the customer with the Id.

    .PARAMETER Filter
    Name of the Vault to Filter
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-VaultList -CustomerId "3e2c14de-c28f-4297-826a-cc645b725be2"

    Name                  VaultID                              Description                               AuthenticationMethod Users
    ----                  -------                              -----------                               -------------------- -----
    Safe                  cdff346b-509e-4aaa-bbc6-bca9d4294ff5 Meine ganz sicheren Passworte             PASSWORD             {@{id=e35002c3-4d90-45b0-93a9-6668add6aae1; role=ADMIN}}

#>
function Get-VaultList {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken,
        [Parameter(Mandatory = $false)]
        $CustomerId,
        [Parameter(Mandatory = $false)]
        $Filter
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $reqBody = @{  
            'customerId' = $CustomerId
            'filter'     = $Filter
        }

        $url = "https://api-ms.server-eye.de/3/vault"

        $Results = Intern-GetJson -url $url  -body $reqBody -authtoken $AuthToken

        

        foreach ($Result in $Results) {
            $TypeName = if ($Result.distributorId) { 
                "distributor" 
            }
            elseif ($Result.customerId) { 
                "customer" 
            }
            elseif ($result.userId) { 
                "User" 
            }
            $ID = if ($Result.distributorId) { 
                $Result.distributorId 
            }
            elseif ($Result.customerId) {
                $Result.customerId 
            }
            elseif ($result.userId) { 
                $result.userId 
            }
    
            $type = [PSCustomObject]@{
                TypeName = $TypeName
                ID       = $ID
            }
            [PSCustomObject]@{
                Name                 = $result.Name
                VaultID              = $result.ID
                Description          = $Result.description
                AuthenticationMethod = $Result.authenticationMethod
                Users                = $Result.users
                Entries              = $Result.entries
                Type                 = $type
                ShowPassword         = $Result.showPassword
            }
        }
    }

    End {

    }
}
