 <#
    .SYNOPSIS
    Get a list of all Templates.

    .DESCRIPTION
    Get a list of all Templates.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-Template {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        $AuthToken
    )
    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }

    Process {
            $Templates = Get-SeApiCustomerTemplateList -AuthToken $AuthToken
            foreach ($Template in $Templates){
                [PSCustomObject]@{
                    Name = $template.Name
                    TemplateID = $template.akid
                }
            }
    }
}




