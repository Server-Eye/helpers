 <#
    .SYNOPSIS
    Creates a tag for your customer.
    
    .DESCRIPTION
    Creates a tag for your customer.
    
    .PARAMETER Name
    The Name for the New Group.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    New-SETag -AuthToken $AuthToken -Name Test2

    Name  TagID
    ----  -----
    Test2 d2901ed6-f61c-44a7-99bf-91d63789412d

    .LINK 
    https://api.server-eye.de/docs/2/#/customer/post_customer_tag
#>
function New-Tag {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter()]
        [alias("ApiKey","Session")]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
                $Tag = New-SeApiCustomerTag -AuthToken $AuthToken -name $Name
                [PSCustomObject]@{
                    Name = $Tag.name
                    TagID = $Tag.tid
                }
            }
}


