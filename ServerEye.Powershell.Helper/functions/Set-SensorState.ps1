<#
    .SYNOPSIS
    Write a hint for a state. Depending on the hint type the state is changed to working on, reopen, and so on. 
    
    .DESCRIPTION
    Write a hint for a state. Depending on the hint type the state is changed to working on, reopen, and so on.
    
    .PARAMETER SensorId
    The id of the agent.

    .PARAMETER StateId
    The id of the state.

    .PARAMETER author
    The user id or email address of the author of the hint. If not provided it's the session user.

    .PARAMETER hintType
    The type of the hint.

    .PARAMETER message
    The message of the hint.
    
    .PARAMETER assignedUser
    The user that is assigned to this hint. e.g the user that is responsible to fix an alert.

    .PARAMETER mentionedUsers
    The users that should receive an information mail. A comma seperated list or array of IDs or email addresses.
    
    .PARAMETER private
    Is this note only visible to the posters customer?

    .PARAMETER until
    If you are working on this state, how long will it take? 0 for forever, 1 for one houer, 2 for two hours and so on.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE

    Set-SensorState -SensorId "9eee802c-ad41-4e1a-8254-ab5b6350cc76" -StateId "447129877"  -author "rene.thulke@server-eye.de" -hintType working -message "Test working" -assignedUser "christian.steuer@server-eye.de" -mentionedUsers "simone.frey@server-eye.de" -until 100

    Name           : HDD C:\
SensorType     : Drive Space
SensorTypeID   : 9BB0B56D-F012-456f-8E20-F3E37E8166D9
SensorId       : 9eee802c-ad41-4e1a-8254-ab5b6350cc76
StateId        : 447129877
HintID         : 93399034
Hinttype       : 0
Message        : Test working
Author         : rene.thulke@server-eye.de
Assigend       : christian.steuer@server-eye.de
Private        : False
Until          : 29.05.2020 11:38:44
Date           : 25.05.2020 07:38:44
mentionedUsers : simone.frey@server-eye.de
#>
function Set-SensorState {
    [CmdletBinding(DefaultParameterSetName = "")]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the agent.")]
        [ValidateNotNullOrEmpty()]
        [Alias("aid")]
        [guid]
        $SensorId,

        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = "The id of the state.")]
        [ValidateNotNullOrEmpty()]
        [Alias("sid")]
        [string]
        $StateId,

        [parameter(Mandatory = $false,
            HelpMessage = "The user id or email address of the author of the hint. If not provided it's the session user.")]
        [string]
        $author,

        [parameter(Mandatory = $true,
            HelpMessage = "The type of the hint.")]
        [ValidateSet("working", "reopen", "false alert", "hint")]
        [string]
        $hintType,

        [parameter(Mandatory = $true,
            HelpMessage = "The message of the hint.")]
        [string]
        $message,
        
        [parameter(Mandatory = $false,
            HelpMessage = "The user that is assigned to this hint. e.g the user that is responsible to fix an alert.")]
        [string]
        $assignedUser,

        [parameter(Mandatory = $false,
            HelpMessage = "The users that should receive an information mail. A comma seperated list or array of IDs or email addresses.")]
        [string[]]
        $mentionedUsers,

        [parameter(Mandatory = $false,
            HelpMessage = "Is this note only visible to the posters customer?")]
        [switch]
        $private,

        [parameter(Mandatory = $false,
            HelpMessage = "If you are working on this state, how long will it take? 0 for forever, 1 for one houer, 2 for two hours and so on.")]
        [int]
        $until,

        [Parameter(Mandatory = $false,
            HelpMessage = "Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $state = New-SeApiAgentStateHint -AId $SensorId -SId $StateId -Author $author -HintType $hintType -Message $message -AssignedUser $assignedUser -MentionedUsers $mentionedUsers -Private ($private.ToString()).ToLower() -Until ([DateTimeOffset](((Get-Date).addhours($until)).ToUniversalTime())).ToUnixTimeMilliseconds() -AuthToken $AuthToken
        Write-Debug "New State: $state"
        $sensor = Get-SESensor -SensorID $SensorId -AuthToken $AuthToken
        Write-Debug "Sensor: $sensor"

        [PSCustomObject]@{
            Name = $sensor.Name
            SensorType = $Sensor.SensorType
            SensorTypeID = $Sensor.SensorTypeID
            SensorId = $Sensor.SensorId
            StateId = $state.sId
            HintID = $state.hId
            Hinttype = If ($state.Hinttype -eq 0) { "working" }elseif ($state.Hinttype -eq 1) {"reopen"}elseif ($state.Hinttype -eq 2) {"false alert"}elseif ($state.Hinttype -eq 3) {"hint"}
            Message = $state.message
            Author = $state.author.email
            Assigend = $state.assigned.email
            Private = $state.private
            Until = $state.until
            Date = $state.date
            mentionedUsers = $state.mentionedUsers.email
        }
    }
}