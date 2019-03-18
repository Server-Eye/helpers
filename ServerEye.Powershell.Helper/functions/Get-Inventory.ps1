<#
    .SYNOPSIS
    Get a list of all OCC-Connector for the given customer. 

    .PARAMETER Filter
    Filter the list to show only matching OCC-Connector. OCC-Connector are filterd based on the name of the OCC-Connector.

    .PARAMETER CustomerId
    The customer id for which the OCC-Connector will be displayed.

    .PARAMETER ConnectorID
    The OCC-Connector with this ID will be displayed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer -Filter "Systemmanager*" | Get-SEOCCConnector

    Customer         Name                 ConnectorID                          MachineName
    --------         ----                 -----------                          -----------
    Systemmanager IT kraemerit.de         e7ef5c26-7f76-4a51-94a7-0e5046a85d55 NB-RP-T460S
    Systemmanager IT kraemerit.de         e408d8fa-a4e1-46d5-9a11-a449e130e6d2 NB-STS
    Systemmanager IT lab.server-eye.local a3738817-4b84-4418-8629-ce2c11f13678 DC
    Systemmanager IT Roadshow AiO 2017    b933bac0-954c-4b4e-958b-06d05d20e8ea AIO-1248...
    Systemmanager IT WORKGROUP            918c8ec3-d879-46c2-81a6-6b5ed9156899 NUC-1309...


    .LINK 
    https://api.server-eye.de/docs/2/
    
#>

function Get-Inventory {
    [CmdletBinding(DefaultParameterSetName = "bySensorhub")]
    Param(
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "bySensorhub", Mandatory = $True)]
        $SensorhubId,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin{
    $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process{
        if ($SensorhubId) {
            formatInvetoryBySensorhub -SensorhubID $SensorhubId -Auth $AuthToken
        }
        
    }
    End {
        
    }
}


function formatInvetoryBySensorhub ($SensorhubId, $auth) {
    $inventory      = Get-SeApiContainerInventory -AuthToken $Auth -CId $SensorhubId -Format json
    $sensorhub      = Get-SESensorhub -SensorhubID $Sensorhubid
    [PSCustomObject]@{
        Customer        = $sensorhub.Customer
        "OCC Connector" = $sensorhub."OCC-Connector"
        Sensorhub       = $sensorhub.name
        CPU             = $inventory.cpu.CPUName
        RAM             = $inventory.Memory.PHYSICALTOTAL 
        "HDD Name"      = $(if ($inventory.disk.FILESYSTEM -eq "NTFS") {$inventory.disk.Disk})
        "HDD Kap."      = $(if (($inventory.disk.FILESYSTEM) -eq "NTFS") {$inventory.disk.Capacity}) 
        "HDD Free"      = $(if (($inventory.disk.FILESYSTEM) -eq "NTFS") {$inventory.disk.Freespace})
        OS              = $inventory.Os.OSname
        "OS Procuktkey" = $inventory.OS.PRODUCTKEY
    }
}