 <#
    .SYNOPSIS
    Creates a new Group in the OCC.
    
    .DESCRIPTION
    Creates a new Group in the OCC.
    
    .PARAMETER Name
    The Name for the New Group.

    .PARAMETER customerId
    The ID of the Customer the Group should .
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
#>
function New-Group {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true))]
        [string]$CustomerId,
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
                $Group = New-SeApiGroup -AuthToken $AuthToken -customerId $CustomerId -name $Name
                [PSCustomObject]@{
                    Name = $Group.Surname
                    GroupId = $Group.gid
                    CustomerID = $Group.customerId
                }
            }
}


