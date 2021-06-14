<#
    .SYNOPSIS
    Create Vault Entry
    
    .DESCRIPTION
    Creates an Entry in the given Vault with the given Data

    .PARAMETER name
    Name of the entry

    .PARAMETER description
    Description for the entry

    .PARAMETER vaultId
    ID of the Vault,

    .PARAMETER token
    A token created with New-SEAuthCacheToken
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function New-VaultEntry {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $description,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSCredential]$credentials = (Get-Credential -Title "Credential to be stored?"),
        [Parameter(Mandatory = $true)]
        $vaultId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $token = $Global:ServerEyeAuthCacheToken,

        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        if ($null -eq $token) {
            $token = New-SEAuthCacheToken
        }
        if ([string]::IsNullOrEmpty($credentials.GetNetworkCredential().Domain) -eq 0) {
            $reqBody = @{  
                'name'        = $name
                'description' = $description
                'credentials' = @{
                    "username" = @{
                        "value"     = $credentials.GetNetworkCredential().UserName
                        "encrypted" = $false
                    }
                    "password" = @{
                        "value"     = $credentials.GetNetworkCredential().Password
                        "encrypted" = $true
                    }
                    "domain"   = @{
                        "value"     = $credentials.GetNetworkCredential().Domain
                        "encrypted" = $false
                    }
                }
                'token'       = $token
            }
        }
        else {
            $reqBody = @{  
                'name'        = $name
                'description' = $description
                'credentials' = @{
                    "username" = @{
                        "value"     = $credentials.GetNetworkCredential().UserName
                        "encrypted" = $false
                    }
                    "password" = @{
                        "value"     = $credentials.GetNetworkCredential().Password
                        "encrypted" = $true
                    }
                }
                'token'       = $token
            }
        }

        $url = "https://api-ms.server-eye.de/3/vault/$vaultID/entry"

        Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken
    }

    End {

    }

}
