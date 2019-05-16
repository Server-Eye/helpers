<#
    .SYNOPSIS
    Get a Count of all Sensor for a Customer. 
    
    .DESCRIPTION
    Get a Count of all Sensor for a Customer. 

    .PARAMETER CustomerId
    Shows the specific customer with this customer Id.

    .EXAMPLE 
    Get-SESensorcount -CustomerId 3e2c14de-c28f-4297-826a-cc645b725be2

    Customer                   Sensor Count
    --------                   ------------
    Wortmann Demo (gesponsert)           58

    .EXAMPLE 
    Get-SECustomer | Get-SESensorcount

    Customer         Sensor Count
    --------         ------------
    Systemmanager IT           57
    RT Privat                   2
    SE Landheim                55
    Server-Eye Su...           19
    Wortmann Demo...           58

    .EXAMPLE 
    Get-SECustomer -all | Get-Sensorcount

    Customer         Sensor Count
    --------         ------------
    Systemmanager IT           57
    RT Privat                   2
    SE Landheim                55
    Server-Eye Su...           19
    Wortmann Demo...           58
    ......

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-Sensorcount {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0,ValueFromPipelineByPropertyName)]
        [string]$CustomerId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [alias("ApiKey", "Session")]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $Customer = Get-SECustomer -CustomerId $CustomerId
        $Sensors = Get-SESensorhub -CustomerId $CustomerId | Get-SESensor
        if (!$Sensors.Count) {
            $Count = 1
        }else {
            $Count = $Sensors.Count
        }

            [PSCustomObject]@{
                Customer = $Customer.Name
                "Sensor Count" = $Count
            }
        }
    End{

    }
}