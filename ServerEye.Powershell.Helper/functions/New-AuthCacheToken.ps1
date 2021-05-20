<#
    .SYNOPSIS
    Create Authtoken
    
    .DESCRIPTION
    Create a Authtoken for the Server-Eye Vaults

    .PARAMETER password
    OCC User Password the token should be created for

    .PARAMETER privateKey
    OCC User privateKey the token should be created for

    .PARAMETER Persist
    Token will be stored to $Global:ServerEyeAuthCacheToken
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function New-AuthCacheToken {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false)]
        [securestring]$password,

        [Parameter(Mandatory = $false)]
        $privateKey,

        [Parameter(Mandatory = $false)]
        [switch] $Persist,      

        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        if (!$password -and !$privateKey) {
            $password = Read-Host -Prompt "OCC Password?" -AsSecureString
        }
        $reqBody = @{  
            'password'   = if ($password) { $password | ConvertFrom-SecureString -AsPlainText }else {
                $null
            }
            'privateKey' = $privateKey
        }

        $url = "https://api-ms.server-eye.de/3/auth/token"

        $Result = Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken
        if ($Persist) {
            $Global:ServerEyeAuthCacheToken = $Result.token   
        }
        Write-Output $result
    }

    End {

    }



}
