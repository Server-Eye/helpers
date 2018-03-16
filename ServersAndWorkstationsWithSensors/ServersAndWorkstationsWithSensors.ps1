[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [switch]$Workstation,
    [switch]$Server
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

if (($Server-eq $false) -and ($Workstation -eq $false) ){
$both = $true
}
$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    
    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                
              if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                If ($both -eq $true){

                     $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                         foreach ($agent in $agents) {
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                            $result += $out
                            }
                }
               If ($Workstation -eq $true){
                    if ($sensorhub.isServer -eq $false) {

                        $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                            foreach ($agent in $agents) {
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                            $result += $out
                            }
                        }
                }
                If ($Server -eq $true){
                    if ($sensorhub.isServer -eq $true) {

                        $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                            foreach ($agent in $agents) {
                            $out = New-Object psobject
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                            $result += $out
                            }
                     }
                }
        }
    }
}
}
}
$result