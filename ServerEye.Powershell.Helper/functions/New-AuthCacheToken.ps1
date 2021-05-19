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
function New-AuthCacheToken {
    [CmdletBinding(DefaultParameterSetName = "byPassword")]
    Param ( 
        [Parameter(Mandatory = $true,ParameterSetName = "ByPassword")]
        [securestring]$password = (Read-Host -Prompt "OCC Password?" -AsSecureString),
        [Parameter(Mandatory = $true,ParameterSetName = "ByKey")]
        $privateKey,
        [Parameter(Mandatory = $false,ParameterSetName = "ByPassword")]
        [Parameter(Mandatory = $false,ParameterSetName = "ByKey")]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        if ($password) {
            $reqBody = @{  
                'password'   = $password | ConvertFrom-SecureString -AsPlainText
            }
        }elseif ($privateKey) {
            $reqBody = @{  
                'privateKey'   = $privateKey
            }
        }

        $url = "https://api-ms.server-eye.de/3/auth/token"

        $Result = Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken
        $Global:ServerEyeAuthCacheToken = $Result.token
        Write-Output $result
    }

    End {

    }



}
