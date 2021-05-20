<#
    .SYNOPSIS
    Import Vault Entry from CSV
    
    .DESCRIPTION
    Import Vault Entry from CSV

    .PARAMETER vaultId
    ID of the Vault

    .PARAMETER PathToCSV
    Full Path to the CSV that should be imported

    .PARAMETER delimiter
    Delemiter used in the CSV

    .PARAMETER token
    A token created with New-SEAuthCacheToken
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Import-VaultEntries {
    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
        $vaultId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        $PathToCSV,

        [Parameter(Mandatory = $false)]
        $delimiter = ";",

        [Parameter(Mandatory = $true)]
        $token = $Global:ServerEyeAuthCacheToken,

        [Parameter(Mandatory = $false)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $content = Get-Content -Path $PathToCSV -Raw -Encoding utf8 
        $reqBody = @{  
            "headers"          = @{
                "id"          = 0
                "name"        = 1
                "description" = 2
                "username"    = 3
                "password"    = 4
                "domain"      = 5
            }
            "content"          = $content
            "delimiter"        = $delimiter
            "quote"            = '""'
            "token"            = $token
            "noHeader"         = $false
            "removeAdditional" = $false
        }
        $url = "https://api-ms.server-eye.de/3/vault/$vaultID/entries/import"
        Intern-PutJson -url $url -body $reqBody -authtoken $AuthToken

    }

    End {

    }
}