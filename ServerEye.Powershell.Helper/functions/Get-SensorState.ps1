<#
    .SYNOPSIS
    Get sensor state. 
    
    .DESCRIPTION
    Gets the current state of a given sensor.

    .PARAMETER SenorId
    The id of a specifc senor. Only this sensor will be show.
   
    .PARAMETER limit
    How many entries of the state history do you need? This param is ignored if start AND end are provided.
        
    .PARAMETER start
    The result will include the raw message data.
        
    .PARAMETER end
    Either an integer which describes how many entries of the history you want to skip or an utc date in milliseconds.
        
    .PARAMETER includeHints
    Include user hints?
        
    .PARAMETER includeMessage
    Include the status message?
        
    .PARAMETER IncludeRawDate
    Include the status' raw data if available?
        
    .PARAMETER format
    In which format do you want the message to be rendered? If the type plain is set, the plain agent message will be returned
 
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 

    Get-SESensorstate -SensorId "bcbfd9d2-98a6-45bb-bca3-b5aaff1bb36f"

    Name          : HDD C:\
    SensorType    : Drive Space
    SensorTypeID  : 9BB0B56D-F012-456f-8E20-F3E37E8166D9
    SensorId      : bcbfd9d2-98a6-45bb-bca3-b5aaff1bb36f
    StateId       : 446362747
    Date          : 22.05.2020 13:24:15
    LastDate      : 22.05.2020 13:39:15
    Error         : False
    Resolved      : False
    SilencedUntil :
    HintCount     : 0
    Hints         :
    Message       :
    Raw           :

    .EXAMPLE 

    Get-SESensorstate -SensorId "bcbfd9d2-98a6-45bb-bca3-b5aaff1bb36f" -includeMessage -includeHints -includeRawData


    Name          : HDD C:\
    SensorType    : Drive Space
    SensorTypeID  : 9BB0B56D-F012-456f-8E20-F3E37E8166D9
    SensorId      : bcbfd9d2-98a6-45bb-bca3-b5aaff1bb36f
    StateId       : 446362747
    Date          : 22.05.2020 13:24:15
    LastDate      : 22.05.2020 13:39:15
    Error         : False
    Resolved      : False
    Resolved      : False
    SilencedUntil :
    HintCount     : 0
    Hints         :
    Message       : Enough space: 10,4 %, 6 GByte
                    --INFO: 1,53 days left till the given treshhold is reached! (based on the current growth)

    Raw           : @{key=main; version=100; state=OK; data=}
#>

function Get-SensorState {
    [CmdletBinding(DefaultParameterSetName = "byLimit")]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the agent/Sensor.")]
        [ValidateNotNullOrEmpty()]
        [Alias("aid")]
        [string]
        $SensorId,

        [parameter(Mandatory = $false,
            ParameterSetName = "byLimit",
            HelpMessage = "How many entries of the state history do you need? This param is ignored if start AND end are provided.")]
        [Int64]
        $limit = 1,

        [parameter(Mandatory = $true,
            ParameterSetName = "byStart",
            HelpMessage = "Either an integer which describes how many entries of the history you want to skip or an utc date in milliseconds.")]
        [parameter(Mandatory = $true,
            ParameterSetName = "byStartEnd",
            HelpMessage = "Either an integer which describes how many entries of the history you want to skip or an utc date in milliseconds.")]
        $start,

        [parameter(Mandatory = $true,
            ParameterSetName = "byStartEnd",
            HelpMessage = "An utc date in milliseconds. Only required if start is an utc timestamp, too.")]
        $end,

        [parameter(Mandatory = $false,
            HelpMessage = "Include user hints?")]
        [switch]
        $includeHints,

        [parameter(Mandatory = $false,
            HelpMessage = "Include the status message?")]
        [switch]
        $includeMessage,

        [parameter(Mandatory = $false,
            HelpMessage = "Include the status' raw data if available?")]
        [Alias("withRawData")]
        [switch]
        $includeRawData,

        [parameter(Mandatory = $false,
            HelpMessage = "In which format do you want the message to be rendered? If the type plain is set, the plain agent message will be returned")]
        [ValidateSet("plain", "html", "html_boxed", "text", "text_short", "mail", "markdown")]
        [string]
        $format = "plain",

        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {

        if ($start -is [int]) {
            Write-Debug "Use Int route"
            $states = Get-SeApiAgentStateList -Aid $SensorId -AuthToken $AuthToken -start $start -includeHints ($includeHints.ToString()).ToLower() -includeMessage ($includeMessage.ToString()).ToLower() -IncludeRawData ($IncludeRawData.ToString()).ToLower() -format $format
        }
        elseif ($start -is [System.DateTime]) {
            Write-Debug "Use DateTime route"
            $states = Get-SeApiAgentStateList -Aid $SensorId -AuthToken $AuthToken -start (([DateTimeOffset](($start).ToUniversalTime())).ToUnixTimeMilliseconds()) -End (([DateTimeOffset](($end).ToUniversalTime())).ToUnixTimeMilliseconds()) -includeHints ($includeHints.ToString()).ToLower() -includeMessage ($includeMessage.ToString()).ToLower() -IncludeRawData ($IncludeRawData.ToString()).ToLower() -format $format
        }
        else {
            Write-Debug "Use Limit/Default route"
            $states = Get-SeApiAgentStateList -Aid $SensorId -AuthToken $AuthToken -Limit $limit -includeHints ($includeHints.ToString()).ToLower() -includeMessage ($includeMessage.ToString()).ToLower() -IncludeRawData ($IncludeRawData.ToString()).ToLower() -format $format

        }
        Write-Debug "Get Sensor Information for ID:$($SensorId)"
        $sensor = Get-CachedAgent -AgentID $sensorId -AuthToken $auth
        $type = $Global:ServerEyeSensorTypes.Get_Item($sensor.type)
        $CC = Get-CachedContainer -ContainerID $sensor.parentId -AuthToken $auth
        $MAC = Get-CachedContainer -AuthToken $auth -ContainerID $CC.parentID
        $customer = Get-CachedCustomer -AuthToken $auth -CustomerId $CC.CustomerId
        Write-Debug "Sensor: $sensor"
        
        foreach ($state in $states) {
            Write-Debug "State: $state"
            [PSCustomObject]@{
                Customer        = $customer.Companyname
                Sensorhub       = $CC.Name
                "OCC-Connector" = $MAC.Name
                Name            = $sensor.Name
                SensorType      = $Type.defaultName
                SensorTypeID    = $Type.agentType
                SensorId        = $state.aId
                StateId         = $state.sId
                Date            = $state.Date
                LastDate        = $state.lastDate
                Error           = $state.state -or $state.forceFailed
                Resolved        = $state.resolved
                SilencedUntil   = (([System.DateTimeOffset]::FromUnixTimeMilliseconds($state.silencedUntil)).DateTime)
                HintCount       = $state.hintCount
                Hints           = $state.hints
                Message         = $state.Message
                Raw             = $state.raw
            }
        }

    }

    End {

    }
}