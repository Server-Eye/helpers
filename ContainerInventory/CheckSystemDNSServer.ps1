[CmdletBinding()]
Param(
    [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(ValueFromPipelineByPropertyName)]
    [alias("CustomerId")]
    $custID
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$containers = Get-SESensorhub -CustomerId $custID

foreach ($sensorhub in $containers) {
    $inventory = Get-SeApiContainerInventory -AuthToken $AuthToken -CId $sensorhub.SensorhubId
    $DNS = $inventory.TCPIP.DNSSERVERS.Split(",")
    [PSCustomObject]@{
        Customer        = $sensorhub.Customer
        Sensorhub       = $sensorhub.Name
        SensorhubId     = $sensorhub.SensorhubId
        Hostname        = $sensorhub.Hostname
        IP              = $inventory.TCPIP.IPADDRESSES
        "Primary DNS"   = $DNS[0]
        "Secondary DNS" = $DNS[1]
    }
}