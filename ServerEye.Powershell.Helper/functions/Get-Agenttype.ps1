 <#
    .SYNOPSIS
    Get a list of all AgentTypes. 
    
    .DESCRIPTION
    Outputs a list of all Agentypes in Server-Eye.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .EXAMPLE 
    Get-SEAgenttype

    Agenttype                                       Agentcategory    AgentTypeID
    ---------                                       -------------    -----------
    Hack Alert                                      Operating System 7CE5A395-0967-4217-BE3C-D2D78DF8C4F7
    CPU Load                                        Operating System B78B0E5E-FC89-435a-95B2-AD23A20F0E38
    Directory File Change                           logfiles         62FE97E1-1F14-47ec-9EBF-8E526F5EE9B7

    .LINK 
    https://api.server-eye.de/docs/2/

#>
function Get-Agenttype {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        $AuthToken
    )
    Begin{
        $AuthToken = Test-Auth -AuthToken $AuthToken
    }
    
    Process {
            $Agenttypes = Get-SeApiAgentTypeList -AuthToken $AuthToken
            foreach ($Agenttype in $Agenttypes){
                [PSCustomObject]@{
                    Agenttype = $Agenttype.defaultName
                    Agentcategory = $Agenttype.category
                    AgentTypeID = $Agenttype.agentType
                }   
            }
            
    }
}


