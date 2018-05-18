 <#
    .SYNOPSIS
    Get a list of all defers. 
    
    .DESCRIPTION
    A list of all defer. 
    
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
            $DispatchTimes = Get-SeApiCustomerDispatchtimeList -AuthToken $AuthToken
            foreach ($dispatchtime in $dispatchtimes){
                [PSCustomObject]@{
                    DispatchTimeName = $dispatchtime.Name
                    DispatchTime = $DispatchTime.defer
                    DispatchTimeID = $DispatchTime.dtID
                }    
            }
            
    }
}


