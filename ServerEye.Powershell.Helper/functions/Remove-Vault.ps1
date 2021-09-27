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
function Remove-Vault {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $true)]
        [string]$vaultId,
        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        $base = "https://api-ms.server-eye.de/3"
    }
    Process {

        $url = "$base/vault/$vaultid"
        try {
            Intern-DeleteJson -url $url -authtoken $AuthToken
            [PSCustomObject]@{
                VaultID = $vaultId
                Remove = $true
            }
        }
        catch {
            [PSCustomObject]@{
                VaultID = $vaultId
                Remove = $false
            }
            Write-Error "Something went wrong $_ "
        }
    }

    End {

    }
}
