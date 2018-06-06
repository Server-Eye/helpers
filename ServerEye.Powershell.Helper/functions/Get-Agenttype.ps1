 <#
    .SYNOPSIS
    Get a list of all AgentTypes. 
    
    .DESCRIPTION
    Get a list of all AgentTypes. 
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
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


