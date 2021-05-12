<#
    .SYNOPSIS
    Get Vault
    
    .DESCRIPTION
     Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates

    .PARAMETER CustomerId
    ID des Kunden bei dem die Einstellungen geändert werden sollen.

    .PARAMETER Filter
    Name der Gruppe die geändert werden soll
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function New-VaultEntry {
    [CmdletBinding(DefaultParameterSetName = "byPassword")]
    Param ( 
        [Parameter(Mandatory = $true, ParameterSetName = "byToken" )]
        [Parameter(Mandatory = $true, ParameterSetName = "byPassword")]
        [Parameter(Mandatory = $true, ParameterSetName = "byKey")]
        $name,
        [Parameter(Mandatory = $true, ParameterSetName = "byToken" )]
        [Parameter(Mandatory = $true, ParameterSetName = "byPassword")]
        [Parameter(Mandatory = $true, ParameterSetName = "byKey")]
        $description,
        [Parameter(Mandatory = $true, ParameterSetName = "byToken" )]
        [Parameter(Mandatory = $true, ParameterSetName = "byPassword")]
        [Parameter(Mandatory = $true, ParameterSetName = "byKey")]
        [PSCredential]$credentials,
        [Parameter(Mandatory = $true, ParameterSetName = "byToken" )]
        [Parameter(Mandatory = $true, ParameterSetName = "byPassword")]
        [Parameter(Mandatory = $true, ParameterSetName = "byKey")]
        $vaultId,
        [Parameter(Mandatory = $true, ParameterSetName = "byPassword")]
        [Security.SecureString]$password = (Read-Host -AsSecureString),
        [Parameter(Mandatory = $true, ParameterSetName = "byKey")]
        $privateKey,
        [Parameter(Mandatory = $false, ParameterSetName = "byToken")]
        $token = $Global:ServerEyeAuthCacheToken,
        [Parameter(Mandatory = $false, ParameterSetName = "byToken" )]
        [Parameter(Mandatory = $false, ParameterSetName = "byPassword")]
        [Parameter(Mandatory = $false, ParameterSetName = "byKey")]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $reqBody = @{  
            'name'        = $name
            'description' = $description
            'credentials' = @{
                "username"= @{
                    "value"= $credentials.GetNetworkCredential().UserName
                    "encrypted"= $false
                }
                "password"= @{
                    "value"= $credentials.GetNetworkCredential().Password
                    "encrypted"= $true
                }
                "domain"= @{
                    "value"= $credentials.GetNetworkCredential().Domain
                    "encrypted"= $false
                }
            }
            'password'    = $password | ConvertFrom-SecureString -AsPlainText
            'privateKey'  = $privateKey
            'token'       = $token

        }

        $url = "https://api-ms.server-eye.de/3/vault/$vaultID/entry"

        Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken

    }

    End {

    }



}
