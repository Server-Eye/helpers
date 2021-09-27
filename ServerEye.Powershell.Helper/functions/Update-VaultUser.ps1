<#
    .SYNOPSIS
    Create Vault
    
    .DESCRIPTION
    Create a new Server-Eye Password Vault

    .PARAMETER name
    Name of the Vault

    .PARAMETER vaultId
    description of the Vault

    .PARAMETER userId
    ID of the User the Vault will accessable
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Update-VaultUser {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $true)]
        $vaultId,

        [Parameter(Mandatory = $true)]
        $userId,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ADMIN", "EDITOR", "READER")]
        $role,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $token = $Global:ServerEyeAuthCacheToken,

        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        $base = "https://api-ms.server-eye.de/3"
        if ($null -eq $token) {
            $token = New-SEAuthCacheToken
        }
    }
    Process {

        $reqBody = @{  
            'role'  = $role
            'token' = $token
        }

        
        $url = "$base/vault/$vaultid/user/$userid"

        $Result = Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken

        Write-Output $Result

    }

    End {

    }
}
