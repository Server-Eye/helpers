  <#
    .SYNOPSIS
    Get Smart Update Categories. 
    
    .DESCRIPTION
    List all Smart Update Categories with their ID.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function Get-SUCategories {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {

        [Collections.Generic.List[string]]$categories = @()

        $response = Invoke-RestMethod -Uri "https://api-ms.server-eye.de/3/smart-updates/categories" -Method Get -WebSession $authtoken
        
        foreach ( $categorie in $response )
        {
            $categories.Add($categorie.id)
        }

         return $categories
    }

    End {

    }
}