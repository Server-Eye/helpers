<#
    .SYNOPSIS
    Get the Inventory for a System.

    .DESCRIPTION
    Get the Inventory for a System, shows CPU, RAM, HDD Name, HDD Capacity, HDD Free Space, OS and OS Procuktkey.

    .PARAMETER SensorhubId
    The sensorhub id for which the Inventory will be displayed.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer -Filter "*Support" | Get-SESensorhub | Get-SEContainerInventory


    .LINK 
    https://api.server-eye.de/docs/2/
    
#>

function Get-ContainerInventory {
    [CmdletBinding(DefaultParameterSetName = "bySensorhub")]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [alias("SensorhubId", "ConnectorId")]
        $ContainerID,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        formatInvetoryOfContainer -ContainerID $ContainerID -AuthToken $AuthToken
    }
    End {
        
    }
}

function formatInvetoryOfContainer ($ContainerID, $AuthToken) {
    $inventory = Get-SeApiContainerInventory -AuthToken $AuthToken -CId $ContainerID -Format json -ErrorAction SilentlyContinue
    $Container = Get-SEContainer -containerid $ContainerID
    if ($Container.ConnectorID) {
        [PSCustomObject]@{
            Customer        = $Container.Customer
            "OCC Connector" = $Container.name
            BIOS = $inventory.BIOS
            CPU = $inventory.CPU
            DEVICES = $inventory.DEVICES
            DISK = $inventory.DISK
            DISPLAY = $inventory.DISPLAY
            DISPLAYMODES = $inventory.DISPLAYMODES
            ENGINES = $inventory.ENGINES
            ENVIRONMENT = $inventory.ENVIRONMENT
            LOCALGROUPS = $inventory.LOCALGROUPS
            LOCALINFO = $inventory.LOCALINFO
            LOCALUSER = $inventory.LOCALUSER
            MACHINE = $inventory.MACHINE
            MEMORY = $inventory.MEMORY
            MEMORYDEVICE = $inventory.MEMORYDEVICE
            MEMORYMODULE = $inventory.MEMORYMODULE
            MONITOR = $inventory.MONITOR
            MSPRODUKT = $inventory.MSPRODUKT
            NTSHARE = $inventory.NTSHARE
            ONBOARDDEVICE = $inventory.ONBOARDDEVICE
            OS = $inventory.OS
            OS_HOTFIX = $inventory.OS_HOTFIX
            PORTSLOT = $inventory.PORTSLOT
            PRINTER = $inventory.PRINTER
            PROGRAMS = $inventory.PROGRAMS
            STARTUP = $inventory.STARTUP
            STORAGE = $inventory.STORAGE
            STORAGEDEVICE = $inventory.STORAGEDEVICE
            SYSTEM = $inventory.System
            SYSTEMSLOT = $inventory.SYSTEMSLOT
            TCPIP = $inventory.TCPIP
            TCPIP_ADAPTER = $inventory.TCPIP_ADAPTER    
        }
    }
    else {
        [PSCustomObject]@{
            Customer        = $Container.Customer
            "OCC Connector" = $Container."OCC-Connector"
            Sensorhub       = $Container.name
            BIOS = $inventory.BIOS
            CPU = $inventory.CPU
            DEVICES = $inventory.DEVICES
            DISK = $inventory.DISK
            DISPLAY = $inventory.DISPLAY
            DISPLAYMODES = $inventory.DISPLAYMODES
            ENGINES = $inventory.ENGINES
            ENVIRONMENT = $inventory.ENVIRONMENT
            LOCALGROUPS = $inventory.LOCALGROUPS
            LOCALINFO = $inventory.LOCALINFO
            LOCALUSER = $inventory.LOCALUSER
            MACHINE = $inventory.MACHINE
            MEMORY = $inventory.MEMORY
            MEMORYDEVICE = $inventory.MEMORYDEVICE
            MEMORYMODULE = $inventory.MEMORYMODULE
            MONITOR = $inventory.MONITOR
            MSPRODUKT = $inventory.MSPRODUKT
            NTSHARE = $inventory.NTSHARE
            ONBOARDDEVICE = $inventory.ONBOARDDEVICE
            OS = $inventory.OS
            OS_HOTFIX = $inventory.OS_HOTFIX
            PORTSLOT = $inventory.PORTSLOT
            PRINTER = $inventory.PRINTER
            PROGRAMS = $inventory.PROGRAMS
            STARTUP = $inventory.STARTUP
            STORAGE = $inventory.STORAGE
            STORAGEDEVICE = $inventory.STORAGEDEVICE
            SYSTEM = $inventory.System
            SYSTEMSLOT = $inventory.SYSTEMSLOT
            TCPIP = $inventory.TCPIP
            TCPIP_ADAPTER = $inventory.TCPIP_ADAPTER
        }
    }

}