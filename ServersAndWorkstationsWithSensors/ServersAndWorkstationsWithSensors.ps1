[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [switch]$Workstation,
    [switch]$Server
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$data = Get-SeApiMyNodesList -Filter customer, agent, container -AuthToken $AuthToken

$result = @()
$customers = $Data | Where-Object { $_.Type -eq 1 }
$Connectors = $Data | Where-Object {$_.Type -eq 2 -and $_.subtype -eq 0}
foreach ($customer in $customers) {
    $Sensorhubs = $Data | Where-Object { $_.Type -eq 2 -and $_.subtype -eq 2 -and $_.customerId -eq $customer.id }
    
    foreach ($Sensorhub in $Sensorhubs) {
        $Connector = $Connectors | Where-Object {$_.id -eq $Sensorhub.parentId}
        If (($Server -eq $false) -and ($Workstation -eq $false)) {

            $Agents = $Data | Where-Object { $_.Type -eq 3 -and $_.parentId -eq $Sensorhub.id}

            foreach ($agent in $agents) {
                $out = New-Object psobject
                $out | Add-Member NoteProperty Kunde ($customer.name)
                $out | Add-Member NoteProperty Netzwerk ($Connector.name)
                $out | Add-Member NoteProperty Server ($sensorhub.name)
                $out | Add-Member NoteProperty Sensor ($agent.name)
                $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                $result += $out
            }
        }
    }
    If ($Workstation -eq $true) {
        if ($sensorhub.isServer -eq $false) {

            $Agents = $Data | Where-Object { $_.Type -eq 3 -and $_.parentId -eq $Sensorhubs.id }

            foreach ($agent in $agents) {
                $out = New-Object psobject
                $out | Add-Member NoteProperty Kunde ($customer.name)
                $out | Add-Member NoteProperty Netzwerk ($Connector.name)
                $out | Add-Member NoteProperty Server ($sensorhub.name)
                $out | Add-Member NoteProperty Sensor ($agent.name)
                $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                $result += $out
            }
        }
    }
    If ($Server -eq $true) {
        if ($sensorhub.isServer -eq $true) {

            $Agents = $Data | Where-Object { $_.Type -eq 3 -and $_.parentId -eq $Sensorhubs.id }

            foreach ($agent in $agents) {
                $out = New-Object psobject
                $out | Add-Member NoteProperty Kunde ($customer.name)
                $out | Add-Member NoteProperty Netzwerk ($Connector.name)
                $out | Add-Member NoteProperty Server ($sensorhub.name)
                $out | Add-Member NoteProperty Sensor ($agent.name)
                $out | Add-Member NoteProperty Tag ($agent.tags.name)                                                     
                $result += $out
            }
        }
    }
}
$result