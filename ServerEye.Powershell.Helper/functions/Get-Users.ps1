 <#
    .SYNOPSIS
    Get a list of all Users. 
    
    .DESCRIPTION
    A list of all User with . 
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-DispatchTime {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        $AuthToken
    )
    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
            $users = Get-SeApiUserList -AuthToken $AuthToken
            foreach ($user in $users){

                [PSCustomObject]@{

                    if ($user.isGroup -eq $true) {
                        Username = $user.surname
                    } 
                    else{
                        $displayName = ("$($user.prename) $($user.surname)".Trim()) 
                        Username = $displayName
                    }
                    EMail = $user.email
                    Company = $user.companyName
                    UserID = $user.uid

                }    
            }
        }        
    }
    End {
    }
}



