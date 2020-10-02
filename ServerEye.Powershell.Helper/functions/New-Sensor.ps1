 <#
    .SYNOPSIS
    Create an agent.
    
    .DESCRIPTION
    Added a new Sensor on to a Sensorhub
    
    .PARAMETER Sensorhubid
    The id of the parent container.

    .PARAMETER typeID
    What type does the agent have? Use Get-SEAgentType to list all valid agent types.

    .PARAMETER Name
    The name of the agent. If not set a matching default name will be used.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    New-Sensor -sensorhubid "cea93445-1330-4598-8d8c-075baf3c3f09" -typeID "0000CBF2-63AA-4911-B26D-924C9FC7ABA6" -Name "Test"

    Name          : Test
    SensorType    : Managed Windows Defender
    SensorId      : f6f0072f-2890-403c-bcac-9233b10da216
    Interval      : 60
    Sensorhub     : NB-RT-NEW
    OCC-Connector : kraemerit.de
    Customer      : Server-Eye Support

#>
function New-Sensor {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string]$sensorhubid,
        [Parameter(Mandatory=$true)]
        [alias("type")]
        [string]$typeID,
        [Parameter(Mandatory=$false)]
        [string]$Name,
        [Parameter()]
        [alias("ApiKey","Session")]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
             $newsensor = New-SeApiAgent -AuthToken $AuthToken -Type $typeID -ParentId $sensorhubid -Name $name
             $sensor = Get-SESensor -SensorId $newsensor.aid -AuthToken $AuthToken

                [PSCustomObject]@{
                    Name          = $sensor.Name
                    SensorType    = $sensor.SensorType
                    SensorId      = $sensor.Sensorid
                    Interval      = $sensor.Interval
                    Sensorhub     = $sensor.Sensorhub
                    "OCC-Connector" = $sensor.'OCC-Connector'
                    Customer      = $sensor.Customer
                }
            }
}