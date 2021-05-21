<#
    .SYNOPSIS
    Get a Vault
    
    .DESCRIPTION
    Get a specific Vault

    .PARAMETER VaultID
    ID of the Vault

    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-Vault {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $VaultID
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $url = "https://api-ms.server-eye.de/3/vault/$VaultID "

        $result = Intern-GetJson -url $url -authtoken $AuthToken
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

    End {

    }
}
