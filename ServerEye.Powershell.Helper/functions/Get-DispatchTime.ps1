<#
    .SYNOPSIS
    Get a list of all defers. 
    
    .DESCRIPTION
    A list of all defer with the ids, the id is needed to set a defertime for a Notification. 
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
     Get-SEDispatchTime

    DispatchTimeName   DispatchTime DispatchTimeID
    ----------------   ------------ --------------
    zum Chef                   4000 0f6620a1-c8ba-4303-9a55-7ee787251fed
    Super Verzoegerung         1000 3c7515c0-08d5-11e4-84b3-7989e625e2af
    Super Eskalation            300 6a2602e1-e1e7-4bf5-9459-7eb910230076
    sehr kurz                     5 7e4ccc30-5107-11e3-88c2-e79efd7f4c3d
    Eskalation                  120 825d6fcf-3666-4c8c-913a-dc4dc88c93c4
    15min                        15 85199c20-a377-11e2-8c77-9de7b8e3f598
    kurz                         10 8981bc65-930e-4bf2-9e82-a61d1417b405
    Verzögerungszeit             90 a02b0540-d265-11e2-9be8-0d7ec789ed90
    lang                         25 a4dd056d-43bf-42b8-a49b-754248eedad6
    Super Extrem               2000 c15a2c35-3e64-41c7-be89-0af7ae27c41d
    zeitverzögerung              30 c6123250-b7ae-11e2-9d76-9f90a0bddf5c
    wirklich kurz                 1 d5d7a2f0-64d8-11e4-92f3-c5a128ca2ddf

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-DispatchTime {
    [CmdletBinding(DefaultParameterSetName = 'byFilter')]
    Param(
        $AuthToken
    )
    Begin {
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        $DispatchTimes = Get-SeApiCustomerDispatchtimeList -AuthToken $AuthToken
        foreach ($dispatchtime in $dispatchtimes) {
            [PSCustomObject]@{
                DispatchTimeName = $dispatchtime.Name
                DispatchTime     = $DispatchTime.defer
                DispatchTimeID   = $DispatchTime.dtID
            }    
        }
            
    }
}


