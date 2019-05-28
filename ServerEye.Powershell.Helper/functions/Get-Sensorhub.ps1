 <#
    .SYNOPSIS
    Get a list of all Sensorhubs for the given customer. 

    .PARAMETER Filter
    Filter the list to show only matching Sensorhubs. Sensorhubs are filterd based on the name of the Sensorhub.

    .PARAMETER CustomerId
    The customer id for which the Sensorhubs will be displayed.

    .PARAMETER SensorhubID
    The Sensorhib with this ID will be displayed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .EXAMPLE 
    Get-SECustomer -Filter "Server*" | Get-SESensorhub

    Name                : NB-RT-NEW
    IsServer            : False
    IsVM                : False
    OCC-Connector       : kraemerit.de
    Customer            : Server-Eye Support
    SensorhubId         : cea93445-1330-4598-8d8c-075baf3c3f09
    Hostname            : NB-RT-NEW
    OsName              : Microsoft Windows 10 Pro
    OsVersion           : 10.0.17763
    OsServicepack       : 0.0
    Architecture        : 64
    Ip                  : {fe80::4899:aa80:ba7:3a05%25, 10.105.10.186}
    PublicIp            : 24.134.40.153
    LastBootTime        : 28.05.2019 06:13:50
    LastRebootInfo      : @{Reason=Anderer Grund (nicht geplant); Action=Ausschalten; Comment=; User=KRAEMERIT\rene.thulke}
    NumberOfProcessors  : 1
    TotalRam            : 8118
    maxHeartbeatTimeout : 20
    alertOffline        : False
    alertShutdown       : False

    .EXAMPLE
    Get-Sensorhub -SensorhubId "cea93445-1330-4598-8d8c-075baf3c3f09"

    Name                : NB-RT-NEW
    IsServer            : False
    IsVM                : False
    OCC-Connector       : kraemerit.de
    Customer            : Server-Eye Support
    SensorhubId         : cea93445-1330-4598-8d8c-075baf3c3f09
    Hostname            : NB-RT-NEW
    OsName              : Microsoft Windows 10 Pro
    OsVersion           : 10.0.17763
    OsServicepack       : 0.0
    Architecture        : 64
    Ip                  : {fe80::4899:aa80:ba7:3a05%25, 10.105.10.186}
    PublicIp            : 24.134.40.153
    LastBootTime        : 28.05.2019 06:13:50
    LastRebootInfo      : @{Reason=Anderer Grund (nicht geplant); Action=Ausschalten; Comment=; User=KRAEMERIT\rene.thulke}
    NumberOfProcessors  : 1
    TotalRam            : 8118
    maxHeartbeatTimeout : 20
    alertOffline        : False
    alertShutdown       : False
#>

function Get-Sensorhub {
    [CmdletBinding(DefaultParameterSetName="byCustomer")]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName="byCustomer",Position=0)]
        [string]$Filter,
        [Parameter(Mandatory=$false,ParameterSetName="byCustomer")]
        [string]$FilterByConnector,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="byCustomer")]
        $CustomerId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="bySensorhub")]
        $SensorhubId,
        [Parameter(Mandatory=$false,ParameterSetName="byCustomer")]
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if ($CustomerId) {
            getSensorhubByCustomer -customerId $CustomerId -filter $Filter -filterByConnector $FilterByConnector -auth $AuthToken
        } elseif ($SensorhubId) {
            getSensorhubById -sensorhubId $SensorhubId -auth $AuthToken
        } else {
            Write-Error "Please provide a SensorhubId or a CustomerId."
        }
    }

    End {

    }
}


function getSensorhubById($sensorhubId, $auth) {
    $sensorhub = Get-SeApiContainer -CId $sensorhubId -AuthToken $auth
    $occConnector = Get-SeApiContainer -CId $sensorhub.parentId -AuthToken $auth
    $customer = Get-SECustomer -customerId $sensorhub.customerId

    [PSCustomObject]@{
        Name = $sensorhub.name
        IsServer = $sensorhub.isServer
        IsVM = $sensorhub.isVm
        'OCC-Connector' = $occConnector.name
        Customer = $customer.name
        SensorhubId = $sensorhub.cId
        Hostname = $sensorhub.machineName
        OsName = $sensorhub.osName
        OsVersion = $sensorhub.osVersion
        OsServicepack = $sensorhub.osServicePack
        Architecture = $sensorhub.architecture
        Ip = $sensorhub.ip
        PublicIp = $sensorhub.publicIp
        LastBootTime = (([datetime]'1/1/1970').AddSeconds([int]($sensorhub.lastBootUpTime / 1000)))
        LastRebootInfo = [PSCustomObject]@{ 
            Reason = $sensorhub.lastRebootInfo.reason
            Action = $sensorhub.lastRebootInfo.action
            Comment = $sensorhub.lastRebootInfo.comment
            User = $sensorhub.lastRebootInfo.user
        }
        NumberOfProcessors = $sensorhub.numberOfProcessors
        TotalRam = [math]::Ceiling($sensorhub.totalRam /1024 /1024)
        maxHeartbeatTimeout = $sensorhub.maxHeartbeatTimeout
        alertOffline = $sensorhub.alertOffline
        alertShutdown = $sensorhub.alertShutdown
    }
}

function getSensorhubByCustomer ($customerId, $filter, $filterByConnector, $auth) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $auth -CId $customerId
    foreach ($container in $containers) {
        if (($container.subtype -eq "0") -and ((-not $filterByConnector) -or ($container.name -like $filterByConnector))  ){ # OCC-Connector
            #        $customer = Get-Customer -customerId $container.customerId
            
            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    if ((-not $filter) -or ($sensorhub.name -like $filter)) {
                        getSensorhubById -sensorhubId $sensorhub.id -auth $auth
                    }
                }
            }
         }
    }
}

