 <#
    .SYNOPSIS
    Get a list of all Tags.

    .DESCRIPTION
    Get a list of all Tags.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-Tag {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
            $Tags = Get-SeApiCustomerTagList -AuthToken $AuthToken
            
            foreach ($Tag in $Tags){
                If($tag.readonly -ne 1){

                    Write-Debug $Tag

                    [PSCustomObject]@{
                        Name = $tag.Name
                        TagID = $tag.tid
                    }
                }
            }
    }
}




