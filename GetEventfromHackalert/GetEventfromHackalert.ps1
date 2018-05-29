 <# 
    .SYNOPSIS
    Show all Event that are alerted by the Hackalert Sensor.

    .DESCRIPTION
    Shows all Event based on the Agent intervall.

    .PARAMETER AgentIntervall 
    Agent intervall from the OCC.
    
#>

Param(
    [Parameter(Mandatory=$true)] 
    $AgentIntervall
 )

$ids=(529,530,531,532,533,534,535,536,537,539,644,672,676,680,681,4625,4740,4768,4772,4776,5461)

$events = Get-WinEvent -Logname "Security" -MaxEvents 1000

$date = (Get-Date).AddMinutes("-" + $AgentIntervall)

foreach ($event in $events){
    foreach($id in $ids){
        if($event.id -eq $id -and $event.Message -notlike "*AgentContainer*" -and $event.TimeCreated -ge $date){
            [PSCustomObject]@{
                ID = $event.ID
                Message = $event.Message
                Time = $event.TimeCreated
            }
        }
    }
}
