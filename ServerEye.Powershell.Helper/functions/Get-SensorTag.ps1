 <#
    .SYNOPSIS
    Get a list of all Tags from a Sensor.

    .DESCRIPTION
    Get a list of all Tags.

    .PARAMETER SenorId
    The id of a specifc senor. Only this sensor will be show.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SESensortag -SensorId 15996915-ca36-408d-a685-8b84943188a7


    Sensorname    : Backupstatus für Veeam Endpoint Backup®
    SensorId      : 15996915-ca36-408d-a685-8b84943188a7
    Sensorhub     : NB-RT-NEW
    OCC-Connector : kraemerit.de
    Customer      : Server-Eye Support
    Tag           : {backup, Wartungsvertrag}


    .EXAMPLE 
    Get-SECustomer -Filter "Server-Eye*"| Get-SESensorhub | Get-SESensor | Get-SESensortag

    Sensorname    : Backupstatus für Veeam Endpoint Backup®
    SensorId      : 15996915-ca36-408d-a685-8b84943188a7
    Sensorhub     : NB-RT-NEW
    OCC-Connector : kraemerit.de
    Customer      : Server-Eye Support
    Tag           : {backup, Wartungsvertrag}

    .LINK 
    https://api.server-eye.de/docs/2/
#>
function Get-Sensortag {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorId,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
            $Tags = Get-SeApiAgentTagList -AId $SensorId -AuthToken $authtoken
            $Sensor = Get-SeApiAgent -AId $sensorId -AuthToken $AuthToken
            $sensorhub = Get-SESensorhub -SensorhubId $Sensor.parentId -AuthToken $AuthToken
        
                [PSCustomObject]@{
                    Sensorname = $sensor.Name
                    SensorId = $sensor.aId
                    Sensorhub = $sensorhub.name
                    'OCC-Connector' = $sensorhub.'OCC-Connector'
                    Customer = $sensorhub.customer
                    Tag = $tags.Name
                }
            
    }
}




