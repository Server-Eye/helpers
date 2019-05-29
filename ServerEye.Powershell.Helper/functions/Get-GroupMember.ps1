 <#
    .SYNOPSIS
    Get a list of all Users in a Group. 
    
    .DESCRIPTION
    Get the users of a specific group.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .PARAMETER groupID
    The id of the group.

    .EXAMPLE
    Get-SEGroupMember -GroupID "a2414265-50b5-41a3-9e6e-be410db72179"

    Group          Username             EMail                              UserID
    -----          --------             -----                              ------
    Exchange Gurus Max Muster           max.muster@server-eye.de           049647d7-48a3-4d0e-b3eb-00995aee77ea
    Exchange Gurus Julian Recktenwald   julian.recktenwald@server-eye.de   0c1d90fe-a016-44e8-8358-40e2fed589f7
    Exchange Gurus Thomas Krammes       thomas.krammes@server-eye.de       14dff442-a455-4233-a337-bda82c518d8b
    Exchange Gurus Julian Weber         julian.weber@server-eye.de         160e926b-de39-4681-ab43-b674c15cbd41

    .EXAMPLE
    Get-SEUser | Where-Object email -eq $null | Get-SEGroupMember

    Group                    Username  EMail                       UserID
    -----                    --------  -----                       ------
    Tanss Webcast            test test tobias.weber2@server-eye.de cf34ed69-1995-4d5a-b1a6-cb9a847e2b40
    Datev Gruppe             test test tobias.weber2@server-eye.de cf34ed69-1995-4d5a-b1a6-cb9a847e2b40
    Managed Service Roadshow test test tobias.weber2@server-eye.de cf34ed69-1995-4d5a-b1a6-cb9a847e2b40
    Tanss Test Gruppe        test test tobias.weber2@server-eye.de cf34ed69-1995-4d5a-b1a6-cb9a847e2b40
    Tanss Webcast Test       test test tobias.weber2@server-eye.de cf34ed69-1995-4d5a-b1a6-cb9a847e2b40
    Server-Eye Webcast       Max Mu... max.muster@server-eye.de    049647d7-48a3-4d0e-b3eb-00995aee77ea
    Server-Eye Webcast       Julian... julian.recktenwald@serve... 0c1d90fe-a016-44e8-8358-40e2fed589f7
        
#>
function Get-GroupMember {
    [CmdletBinding()]
    Param(
        [Alias("UserID")]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        $GroupID,
        $AuthToken

    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        $users = Get-SeApiGroupUserList -AuthToken $AuthToken -gid $GroupID | Where-Object checked -eq $true
        $Group = Get-SEUser | Where-Object UserID -EQ $GroupID
        if (!$users) {
            formatNoUser -user $User -group $Group
        }else {
            foreach ($user in $users){
                formatGroupUser -user $user -group $group
            }
        }
    }        
    
    End {
    }
}

function formatGroupUser($user, $group) {
    [PSCustomObject]@{
        Group = $group.Username
        Username = ("$($user.prename) $($user.surname)".Trim())
        EMail = $user.email
        UserID = $user.uId
        GroupID = $group.UserID
    }
}
function formatNoUser($user, $group) {
    [PSCustomObject]@{
        Group = $group.Username
        Username = "No User in Group"
        EMail = ""
        UserID = ""
        GroupID = $group.UserID
    }
}