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

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [PSCredential]$credentials = (Get-Credential -Title "Credential to be stored?"),
        
        [Parameter(Mandatory = $true)]
        $vaultId,

        [Parameter(Mandatory = $true)]
        $externalId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $token = $Global:ServerEyeAuthCacheToken,

        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        $base = "https://api-ms.server-eye.de/3"
    }
    
    Process {
        if ($null -eq $token) {
            $token = New-SEAuthCacheToken
        }
        $reqBody = @{ 
            'name'        = $name
            'description' = $description
            'token'       = $token
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
        }
        if ([string]::IsNullOrEmpty($credentials.GetNetworkCredential().Domain) -eq $false) {
            $reqBody += @{  
                "domain" = @{
                    "value"     = $credentials.GetNetworkCredential().Domain
                    "encrypted" = $false
                }
            }
        }
        if ($externalId) {
            $reqBody += @{  
                "externalId" = $externalId
            }
        }
        Write-Debug ($reqBody | Out-String)
        $url = "$base/vault/$vaultID/entry"

        try {
            Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken
        }
        catch {
            if ($_.ErrorDetails.Message -eq '{"message":"BAD_DECRYPT","error":"UNKNOWN_ERROR"}') {
                throw "Please recreate Token with correct Method, Password or PrivateKey."
                break
            }
            else {
                Write-Output $_
                break
            }
        }
    }

    End {

    }

}
