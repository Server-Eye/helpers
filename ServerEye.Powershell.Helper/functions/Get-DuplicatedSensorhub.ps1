<#
    .SYNOPSIS
    Get a list of all duplicated Sensorhubs for the given customer. 

    .PARAMETER CustomerId
    The customer id for which the Sensorhubs will be displayed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .LINK 
    https://api.server-eye.de/docs/2/#/customer/list_customer_container
    https://api.server-eye.de/docs/2/#/customer/get_customer
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object

    .EXAMPLE 
    Get-SEDuplicatedSensorhub -CustomerId "3e2c14de-c28f-4297-826a-cc645b725be2"

    Customer      : Wortmann Demo (gesponsert)
    SensorhubName : WIN10-001
    SensorhubId   : c7e1418b-533d-477c-96c5-b248a5bcf7be
    Date          : 28.08.2020 12:27:15
    LastDate      : 28.08.2020 12:41:16
    
    .EXAMPLE 
    Get-SECustomer -Filter "Wortmann*" | Get-SEDuplicatedSensorhub | Format-Table

    Customer                   SensorhubName SensorhubId                          Date                LastDate
    --------                   ------------- -----------                          ----                --------
    Wortmann Demo (gesponsert) WIN10-001     c7e1418b-533d-477c-96c5-b248a5bcf7be 28.08.2020 12:27:15 28.08.2020 12:41:16
    Wortmann Demo (gesponsert) WIN10-001     c95b95d9-6a17-4522-82be-0c02820603fa 28.08.2020 12:56:12 03.09.2020 09:04:39
    Wortmann Demo (gesponsert) WIN10-002     2e41e39e-d6c9-425e-a744-1af30c6db9e1 02.09.2020 12:49:44 02.09.2020 12:49:44
    Wortmann Demo (gesponsert) WIN10-002     3d40b71e-8705-4e2f-8ab6-23fd187e8a56 23.07.2020 11:22:15 02.09.2020 12:49:07
    Wortmann Demo (gesponsert) WIN10-002     67ee5e44-0b0a-44d3-8e48-359c932ba938 02.09.2020 12:49:44 03.09.2020 09:06:16
 
#>

function Get-DuplicatedSensorhub {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = "The id of the customer.")]
        [ValidateNotNullOrEmpty()]
        [Alias("cId")]
        [string]
        $CustomerId,
        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $customer = Get-SeApiCustomer -cId $CustomerId -AuthToken $AuthToken
        $Sensorhubs = Get-SeApiCustomerContainerList -AuthToken $AuthToken -cid $CustomerID | Where-Object { $_.subtype -eq 2 }
        $array = $Sensorhubs | Select-Object -Unique -Property Name
        $duplicates = Compare-Object -ReferenceObject $array -DifferenceObject $Sensorhubs -Property Name
        $sensorhubDup = $Sensorhubs | Where-Object { $_.Name -in $duplicates.Name }
        foreach ($sensorhub in $sensorhubDup) {
            [PSCustomObject]@{
                Customer      = $customer.companyName
                SensorhubName = $sensorhub.name
                SensorhubId   = $sensorhub.ID
                Date          = $sensorhub.Date
                LastDate      = $sensorhub.Lastdate
            }

        }


    }

    End {

    }
}

