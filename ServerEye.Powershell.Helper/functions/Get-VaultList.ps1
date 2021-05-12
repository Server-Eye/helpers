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
            [PSCustomObject]@{
                Name = $result.Name
                VaultID = $result.ID
                Description = $Result.description
                AuthenticationMethod = $Result.authenticationMethod
                Users = $Result.users
                Entries = $Result.entries
                Type = [PSCustomObject]@{
                    TypeName = if($Result.distributorId){"distributor"}elseif($Result.customerId) {"customer"}elseif ($result.userId) {"User"}
                    ID = if($Result.distributorId){$Result.distributorId}elseif($Result.customerId) {$Result.customerId}elseif ($result.userId) {$result.userId}
                }
                ShowPassword = $Result.showPassword
            }
        }
    }

    End {

    }



}
