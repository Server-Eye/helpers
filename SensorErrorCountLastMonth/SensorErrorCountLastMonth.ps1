[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [Parameter(Mandatory=$true)]
    $CustomerID
)

$AuthToken = Test-SEAuth -authtoken $AuthToken

$sensors = Get-SESensorhub -CustomerID $CustomerID | Get-SESensor

$now = ([DateTimeOffset]((Get-Date).ToUniversalTime())).ToUnixTimeMilliseconds()
$month = ([DateTimeOffset]((Get-Date).AddMonths(-1).ToUniversalTime())).ToUnixTimeMilliseconds()

foreach($sensor in $sensors){
    $state = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $sensor.sensorID start $month -End $now

    [PSCustomObject]@{ 
        Sensor = $sensor.Name
        SensorID = $sensor.SensorID
        Sensorhub = $sensor.Sensorhub
        Count = $state.Count
    }
} 
