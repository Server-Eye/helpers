 <#
    .SYNOPSIS
    Get a container.
    
    .DESCRIPTION
    Gets all information about a Container, show a OCC Connector or Sensorhub based on the ID.
    
    .PARAMETER containerid
    The id of the container.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

        
    .EXAMPLE 
    # Shows a OCC Connector. 
    Get-SEContainer -containerid "OCC Connector ID"

    Customer           Name         ConnectorID                          MachineName
    --------           ----         -----------                          -----------
    Server-Eye Support kraemerit.de 466655e5-2bb1-4a50-a6b8-037ec50f2855 NB-RT-NEW

    .EXAMPLE 
    # Shows a Sensorhub. 
    Get-SEContainer -containerid "Senorhub ID"

    Name                : NB-RT-NEW
    IsServer            : False
    IsVM                : False
    OCC-Connector       : kraemerit.de
    Customer            : Server-Eye Support
    SensorhubId         : cea93445-1330-4598-8d8c-075baf3c3f09
    Hostname            : NB-RT-NEW
    OsName              : Microsoft Windows 10 Pro
    OsVersion           : 10.0.18362
    OsServicepack       : 0.0
    Architecture        : 64
    Ip                  : {fe80::cd8f:b4ff:cce2:9978%27, 10.105.10.167}
    PublicIp            : 24.134.40.153
    LastBootTime        : 02.09.2019 08:54:58
    LastRebootInfo      : @{Reason=Anderer Grund (nicht geplant); Action=Ausschalten; Comment=; User=KRAEMERIT\rene.thulke}
    NumberOfProcessors  : 1
    TotalRam            : 8118
    maxHeartbeatTimeout : 20
    alertOffline        : False
    alertShutdown       : False

    .LINK 
    https://api.server-eye.de/docs/2/#/container/get_container
#>

function Get-Container {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $containerid,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
        $container = Get-SeApiContainer -cId $containerid -AuthToken $AuthToken
        if ($container.type -eq 0) {
            getOCCConnector -container $container -auth $AuthToken
        }
        if ($container.type -eq 2) {
            getSensorhub -container $container -auth $AuthToken
        }
  

    }

    End{

    }
}

function getOCCConnector($container,$auth) {
    $customer = Get-SeApiCustomer -cId $container.customerId -AuthToken $auth
    $notification = Get-SeApiMyNodesList -Filter container -AuthToken $auth | Where-Object {$_.id -eq $container.cId}

    [PSCustomObject]@{
        Customer    = $customer.companyName
        Name        = $container.name
        ConnectorID = $container.cId
        MachineName = $container.machineName
        HasNotification = $notification.hasNotification
    }
}

function getSensorhub($container, $auth) {
    $occConnector = Get-SeApiContainer -cId $container.parentId -AuthToken $auth
    $customer = Get-SeApiCustomer -cId $container.customerId -AuthToken $auth
    $notification = Get-SeApiMyNodesList -Filter container -AuthToken $auth | Where-Object {$_.id -eq $container.cId}
    [PSCustomObject]@{
        Name = $container.name
        IsServer = $container.isServer
        IsVM = $container.isVm
        'OCC-Connector' = $occConnector.name
        Customer = $customer.companyName
        SensorhubId = $container.cId
        HasNotification = $notification.hasNotification
        Hostname = $container.machineName
        OsName = $container.osName
        OsVersion = $container.osVersion
        OsServicepack = $container.osServicePack
        Architecture = $container.architecture
        Ip = $container.ip
        PublicIp = $container.publicIp
        LastBootTime = (([datetime]'1/1/1970').AddSeconds([int]($container.lastBootUpTime / 1000)))
        LastRebootInfo = [PSCustomObject]@{ 
            Reason = $container.lastRebootInfo.reason
            Action = $container.lastRebootInfo.action
            Comment = $container.lastRebootInfo.comment
            User = $container.lastRebootInfo.user
        }
        NumberOfProcessors = $container.numberOfProcessors
        TotalRam = [math]::Ceiling($container.totalRam /1024 /1024)
        maxHeartbeatTimeout = $container.maxHeartbeatTimeout
        alertOffline = $container.alertOffline
        alertShutdown = $container.alertShutdown
    }
}