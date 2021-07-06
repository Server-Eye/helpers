
<#
AUTOR: This file is auto-generated
DATE: 2021-07-05T09:37:36.758Z
DESC: Module enables easier access to the PowerShell API
#>


    <#
    .SYNOPSIS
    Get an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Get-Agent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all agent categories.

    
    #>
    function Get-AgentCategoryList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/category" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get an agent's chart.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Start
        Start date in milliseconds.
        
        .PARAMETER $End
        End date in milliseconds.
        
        .PARAMETER $ValueType
        Which values do you need?
        
        .PARAMETER $FillGaps
        If there are gaps in the chart, do you want them to be auto-filled with the previous chart value?
        
    #>
    function Get-AgentChart {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$false)]
$Start,
[Parameter(Mandatory=$false)]
$End,
[Parameter(Mandatory=$false)]
[ValidateSet('AVG','MIN','MAX','ALL')]
$ValueType,
[Parameter(Mandatory=$false)]
$FillGaps,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/chart?start=$Start&end=$End&valueType=$ValueType&fillGaps=$FillGaps" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List an agent's notes.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Get-AgentNoteList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/note" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List an agent's notifications.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Get-AgentNotificationList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/notification" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a settings remote information.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Key
        The key of the setting.
        
        .PARAMETER $Information
        An additional information for the agent. Sometimes required. Please check the call made by the OCC for possible values.
        
    #>
    function Get-AgentRemoteSetting {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$Key,
[Parameter(Mandatory=$false)]
$Information,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/setting/$Key/remote?information=$Information" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List an agent's settings.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Get-AgentSettingList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Request a specific state of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $SId
        The id of the state.
        
        .PARAMETER $IncludeHints
        Include user hints?
        
        .PARAMETER $IncludeMessage
        Include the status message?
        
        .PARAMETER $IncludeRawData
        Include the status' raw data if available?
        
        .PARAMETER $Format
        In which format do you want the message to be rendered? If the type plain is set, the plain agent message will be returned
        
    #>
    function Get-AgentState {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$SId,
[Parameter(Mandatory=$false)]
$IncludeHints,
[Parameter(Mandatory=$false)]
$IncludeMessage,
[Parameter(Mandatory=$false)]
$IncludeRawData,
[Parameter(Mandatory=$false)]
[ValidateSet('plain','html','html_boxed','text','text_short','mail','markdown')]
$Format,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/state/$SId?includeHints=$IncludeHints&includeMessage=$IncludeMessage&includeRawData=$IncludeRawData&format=$Format" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the current state or a state history of this agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Limit
        How many entries of the state history do you need? <b>This param is ignored if start AND end are provided.</b>
        
        .PARAMETER $Start
        Either an integer which describes how many entries of the history you want to skip or an utc date in milliseconds.
        
        .PARAMETER $End
        An utc date in milliseconds. Only required if start is an utc timestamp, too.
        
        .PARAMETER $IncludeHints
        Include user hints?
        
        .PARAMETER $IncludeMessage
        Include the status message?
        
        .PARAMETER $IncludeRawData
        Include the status' raw data if available?
        
        .PARAMETER $Format
        In which format do you want the message to be rendered? If the type plain is set, the plain agent message will be returned
        
    #>
    function Get-AgentStateList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$false)]
$Limit,
[Parameter(Mandatory=$false)]
$Start,
[Parameter(Mandatory=$false)]
$End,
[Parameter(Mandatory=$false)]
$IncludeHints,
[Parameter(Mandatory=$false)]
$IncludeMessage,
[Parameter(Mandatory=$false)]
$IncludeRawData,
[Parameter(Mandatory=$false)]
[ValidateSet('plain','html','html_boxed','text','text_short','mail','markdown')]
$Format,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/state?limit=$Limit&start=$Start&end=$End&includeHints=$IncludeHints&includeMessage=$IncludeMessage&includeRawData=$IncludeRawData&format=$Format" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List an agent's tags.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Get-AgentTagList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AId/tag" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the known FAQ's for an agent type

    
        .PARAMETER $AkId
        The id of the agent type.
        
    #>
    function Get-AgentTypeFaqList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AkId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/type/$AkId/faq" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all possible agent types.

    
        .PARAMETER $Category
        List only agent types of a specific category. For possible categories see <code>GET /agent/category</code>.
        
    #>
    function Get-AgentTypeList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$false)]
$Category,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/type?category=$Category" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the settings and default values of an agent type.

    
        .PARAMETER $AkId
        The id of the agent type.
        
    #>
    function Get-AgentTypeSettingList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AkId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/agent/type/$AkId/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a container.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List a container's agents.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-ContainerAgentList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/agents" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a container's inventory.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $Format
        What kind of return format do you expect?
        
    #>
    function Get-ContainerInventory {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
[ValidateSet('json','xml')]
$Format,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/inventory?format=$Format" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List a container's notes.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-ContainerNoteList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/note" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List a container's notifications.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-ContainerNotificationList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/notification" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a container's proposals.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-ContainerProposalList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/proposal" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the settings of a proposal.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $PId
        The id of the proposal.
        
    #>
    function Get-ContainerProposalSettingList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$PId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/proposal/$PId/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    A specific of this container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $SId
        The id of the state.
        
        .PARAMETER $IncludeHints
        Include user hints?
        
        .PARAMETER $IncludeMessage
        Include the status message?
        
    #>
    function Get-ContainerState {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$SId,
[Parameter(Mandatory=$false)]
$IncludeHints,
[Parameter(Mandatory=$false)]
$IncludeMessage,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/state/$SId?includeHints=$IncludeHints&includeMessage=$IncludeMessage" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the current state or a state history of this container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $Limit
        How many entries of the state history do you need? <b>This param is ignored if start AND end are provided.</b>
        
        .PARAMETER $Start
        Either an integer which describes how many entries of the history you want to skip or an utc date in milliseconds.
        
        .PARAMETER $End
        An utc date in milliseconds. Only required if start is an utc timestamp, too.
        
        .PARAMETER $IncludeHints
        Include user hints?
        
        .PARAMETER $IncludeMessage
        Include the status message?
        
    #>
    function Get-ContainerStateList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$Limit,
[Parameter(Mandatory=$false)]
$Start,
[Parameter(Mandatory=$false)]
$End,
[Parameter(Mandatory=$false)]
$IncludeHints,
[Parameter(Mandatory=$false)]
$IncludeMessage,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/state?limit=$Limit&start=$Start&end=$End&includeHints=$IncludeHints&includeMessage=$IncludeMessage" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List a container's tags.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-ContainerTagList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/container/$CId/tag" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a customer of your distributor.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-Customer {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a specific api key.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Name
        The name of the api key you want to read.
        
    #>
    function Get-CustomerApikey {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/apiKey?name=$Name" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get your distributor's, its customer's and their user's api keys.

    
    #>
    function Get-CustomerApikeyList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/apiKey" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all buckets of a customer

    
    #>
    function Get-CustomerBucketList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/bucket" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all users of a bucket

    
        .PARAMETER $BId
        The id of the bucket.
        
    #>
    function Get-CustomerBucketUserList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/bucket/$BId/user" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List a customer's containers.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerContainerList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/containers" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all deferred dispatch times of a customer

    
    #>
    function Get-CustomerDispatchtimeList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/dispatchTime" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns all licenses of a customer.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerLicenseList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/license" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all customers of your distributor.

    
    #>
    function Get-CustomerList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns the customers location.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerLocation {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/location" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all managers of a customer.

    
        .PARAMETER $CId
        The customer id.
        
    #>
    function Get-CustomerManagerList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/manager" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns all customer properties.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerPropertyList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/property" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a customers secretKey.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerSecret {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/secret" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List customer settings.

    
        .PARAMETER $CId
        The id of the customer.
        
    #>
    function Get-CustomerSettingList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all tags of a customer

    
    #>
    function Get-CustomerTagList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/tag" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List the agents of one of your container templates.

    
        .PARAMETER $TId
        The id of the template.
        
    #>
    function Get-CustomerTemplateAgentList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/template/$TId/agent" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all container templates of your customer.

    
    #>
    function Get-CustomerTemplateList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/template" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a customer's usage data. Returns the number of agents, containers, ... for a specific month.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Year
        Year of the usage.
        
        .PARAMETER $Month
        Month of the usage.
        
    #>
    function Get-CustomerUsage {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Year,
[Parameter(Mandatory=$true)]
[ValidateSet('1','2','3','4','5','6','7','8','9','10','11','12')]
$Month,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CId/usage?year=$Year&month=$Month" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get usage data of your distributor's customers. Returns the number of agents, containers, ... for a specific month.

    
        .PARAMETER $Year
        Year of the usage.
        
        .PARAMETER $Month
        Month of the usage.
        
    #>
    function Get-CustomerUsageList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Year,
[Parameter(Mandatory=$true)]
[ValidateSet('1','2','3','4','5','6','7','8','9','10','11','12')]
$Month,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/usage?year=$Year&month=$Month" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all view filters of a customer

    
    #>
    function Get-CustomerViewfilterList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/viewFilter" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a specific group.

    
        .PARAMETER $GId
        The id of the group.
        
    #>
    function Get-Group {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/group/$GId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get all groups.

    
    #>
    function Get-GroupList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/group" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the users of a specific group.

    
        .PARAMETER $GId
        The id of the group.
        
    #>
    function Get-GroupUserList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/group/$GId/user" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Searches for one of your api keys by name.

    
        .PARAMETER $Name
        The name of the wanted key.
        
    #>
    function Get-Key {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/key?name=$Name" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns your user object.

    
    #>
    function Get-Me {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns your customer object.

    
    #>
    function Get-MyCustomer {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/customer" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns your last known location.

    
    #>
    function Get-MyLocation {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/location" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Checks if you have already registered your mobile push handle.

    
        .PARAMETER $Handle
        The Android or iOS push handle.
        
    #>
    function Get-MyMobilepush {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Handle,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/mobilepush/$Handle" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    A list of all registered push handles of your devices.

    
    #>
    function Get-MyMobilepushList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/mobilepush" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    A list of all your nodes. That means every customer, container, agent, template, and so on you are allowed to see.

    
        .PARAMETER $ListType
        The way the nodes will be returned, flat array or object.
        
        .PARAMETER $Filter
        Filters are applied to the result data and remove nodes from the result set, that don't match the filters. Can be a comma-seperated list. <b>Note: 'own' can not be combined with 'nativeOnly'!</b>
        
        .PARAMETER $IncludeTemplates
        Do you need all of the templates?
        
        .PARAMETER $IncludeDistributorsCustomers
        Do you need all customers of your distributor?
        
        .PARAMETER $IncludeDistributorsNodes
        If you want all customers, containers and agents of your distributor set this to true. <b>Usually you don't want to do this!</b>
        
    #>
    function Get-MyNodesList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$false)]
[ValidateSet('list','object')]
$ListType,
[Parameter(Mandatory=$false)]
[ValidateSet('user','customer','container','agent','errors','own','nativeOnly')]
$Filter,
[Parameter(Mandatory=$false)]
$IncludeTemplates,
[Parameter(Mandatory=$false)]
$IncludeDistributorsCustomers,
[Parameter(Mandatory=$false)]
$IncludeDistributorsNodes,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/nodes?listType=$ListType&filter=$Filter&includeTemplates=$IncludeTemplates&includeDistributorsCustomers=$IncludeDistributorsCustomers&includeDistributorsNodes=$IncludeDistributorsNodes" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all your notifications.

    
        .PARAMETER $Type
        List the notifications of the user or of its' groups.
        
    #>
    function Get-MyNotificationList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$false)]
[ValidateSet('user','groups')]
$Type,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/notification?type=$Type" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns your user's settings.

    
    #>
    function Get-MySetting {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns the user's two factor authentication settings and if two factor is enabled or not. 

    
    #>
    function Get-MyTwofactor {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/twofactor" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns the user's two factor secret. Returns only successfull if two factor authentication is not enabled and active, yet!

    
        .PARAMETER $Format
        The 6 digit code of the authenticator app to validate the user and prove that you know the correct secret.
        
    #>
    function Get-MyTwofactorSecret {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
[ValidateSet('string','qrcode')]
$Format,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/me/twofactor/secret?format=$Format" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all install jobs you have triggered during your browser session.

    
        .PARAMETER $CustomerId
        The id of the customer of the network.
        
        .PARAMETER $CId
        The id of the OCC Connector within the network.
        
        .PARAMETER $JobIds
        Pass an array of job IDs if you want the status of specific jobs only.
        
    #>
    function Get-NetworkSystemInstallstatusList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$JobIds,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/network/$CustomerId/$CId/system/installstatus?jobIds=$JobIds" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Lists all systems within a Windows Active Directory or Workgroup.

    
        .PARAMETER $CustomerId
        The id of the customer of the network.
        
        .PARAMETER $CId
        The id of the OCC Connector within the network.
        
    #>
    function Get-NetworkSystemList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/network/$CustomerId/$CId/system" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get system details related to remote access.

    
        .PARAMETER $CustomerId
        The id of the customer the container belongs to.
        
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-Pcvisit {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/pcvisit/$CustomerId/$CId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Check if pcvisit is installed on a remote system and start the service.

    
        .PARAMETER $CustomerId
        The id of the customer the container belongs to.
        
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Get-PcvisitCheck {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/pcvisit/$CustomerId/$CId/check" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get details of a reports and its' history.

    
        .PARAMETER $CId
        The id of a customer.
        
        .PARAMETER $RId
        The id of a report of the customer.
        
    #>
    function Get-ReportingCustomReport {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$RId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/reporting/$CId/report/$RId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all defined reports of a customer.

    
        .PARAMETER $CId
        The id of a customer.
        
    #>
    function Get-ReportingCustomReportList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/reporting/$CId/report" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns a report template and its widgets.

    
        .PARAMETER $RtId
        The id of a report template.
        
    #>
    function Get-ReportingTemplate {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$RtId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/reporting/template/$RtId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List all available report templates.

    
    #>
    function Get-ReportingTemplateList {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/reporting/template" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Generate a code and send it by email to reset the password. This code is valid for 24 hours

    
        .PARAMETER $Email
        The mail address, to reset the password
        
        .PARAMETER $Code
        The code for the user (two-factor or received sms code)
        
    #>
    function Get-Reset {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Email,
[Parameter(Mandatory=$false)]
$Code,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/auth/reset?email=$Email&code=$Code" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get all users with this specific role.

    
        .PARAMETER $Role
        The role to search for
        
    #>
    function Get-RoleList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','reporting','pcvisit','pm','mav','powershell','tanss')]
$Role,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/role/$Role/user" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a specific user.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Get-User {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/user/$UId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get the groups of a specific user.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Get-UserGroupList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/user/$UId/group" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    List users by criteria. Use a query or a customer id to limit the result data. Otherwise a list of all users of all customers is provided.

    
        .PARAMETER $Query
        A search string the emailaddress or surname or prename must container.
        
        .PARAMETER $CustomerId
        Restrict the result list to a specific customer.
        
        .PARAMETER $IncludeLocation
        Should your result contain the last known location of every user?
        
    #>
    function Get-UserList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$false)]
$Query,
[Parameter(Mandatory=$false)]
$CustomerId,
[Parameter(Mandatory=$false)]
$IncludeLocation,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/user?query=$Query&customerId=$CustomerId&includeLocation=$IncludeLocation" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Get a specific users last known location.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Get-UserLocation {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/user/$UId/location" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Returns a user's settings.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Get-UserSettingList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/user/$UId/setting" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Logs the logged in user out and destroys his session.

    
    #>
    function New-Logout {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/auth/logout" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Empties all the bucket content into the reponse. Warning: Bucket is empty after calling this!

    
        .PARAMETER $BId
        The id of the bucket.
        
    #>
    function Read-CustomerBucket {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-GetJson -url "https://api.server-eye.de/2/customer/bucket/$BId/empty" -authtoken $AuthToken
        }
    }
    
    <#
    .SYNOPSIS
    Add a tag to an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $TId
        The id of the tag.
        
    #>
    function New-AgentTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'tId' = $TId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/agent/$AId/tag/$TId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add a tag to a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $TId
        The id of the tag.
        
    #>
    function New-ContainerTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'tId' = $TId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/container/$CId/tag/$TId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Change an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Name
        The name to display to the user.
        
        .PARAMETER $Interval
        The interval in minutes. The agent will be executed every X minutes.
        
    #>
    function Set-Agent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$false)]
$Name,
[Parameter(Mandatory=$false)]
$Interval,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'name' = $Name
            'interval' = $Interval
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/agent/$AId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update an existing notification of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $NId
        The id of the notification.
        
        .PARAMETER $UserId
        The id of the user or group that should receive a notification.
        
        .PARAMETER $Email
        Send an email as notification.
        
        .PARAMETER $Phone
        Send a phone text message as notification.
        
        .PARAMETER $Ticket
        Create a ticket as notification.
        
        .PARAMETER $DeferId
        Should this notification be triggered with defered dispatch? Pass an ID of a dispatchTime entry.
        
    #>
    function Set-AgentNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$NId,
[Parameter(Mandatory=$false)]
$UserId,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
$Ticket,
[Parameter(Mandatory=$false)]
$DeferId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'nId' = $NId
            'userId' = $UserId
            'email' = $Email
            'phone' = $Phone
            'ticket' = $Ticket
            'deferId' = $DeferId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/agent/$AId/notification/$NId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update an existing setting of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Key
        The key of the setting you want to change. This has to be a currently existing key.
        
        .PARAMETER $Value
        The new value of the setting.
        
    #>
    function Set-AgentSetting {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$Key,
[Parameter(Mandatory=$true)]
$Value,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'key' = $Key
            'value' = $Value
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/agent/$AId/setting/$Key" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates attributes of a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $Name
        The display name of the container
        
        .PARAMETER $AlertOffline
        Send an alert if the container reached maxHeartbeatTimeout.
        
        .PARAMETER $AlertShutdown
        Send an alert if the container reached maxHeartbeatTimeout and has cleanShutdown:true.
        
        .PARAMETER $MaxHeartbeatTimeout
        How many minutes without contact to the cloud are ok for this container?
        
    #>
    function Set-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$Name,
[Parameter(Mandatory=$false)]
$AlertOffline,
[Parameter(Mandatory=$false)]
$AlertShutdown,
[Parameter(Mandatory=$false)]
$MaxHeartbeatTimeout,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'name' = $Name
            'alertOffline' = $AlertOffline
            'alertShutdown' = $AlertShutdown
            'maxHeartbeatTimeout' = $MaxHeartbeatTimeout
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/container/$CId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update an existing notification of a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $NId
        The id of the notification.
        
        .PARAMETER $UserId
        The id of the user or group that should receive a notification.
        
        .PARAMETER $Email
        Send an email as notification.
        
        .PARAMETER $Phone
        Send a phone text message as notification.
        
        .PARAMETER $Ticket
        Create a ticket as notification.
        
        .PARAMETER $DeferId
        Should this notification be triggered with defered dispatch? Pass an ID of a dispatchTime entry.
        
    #>
    function Set-ContainerNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$NId,
[Parameter(Mandatory=$false)]
$UserId,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
$Ticket,
[Parameter(Mandatory=$false)]
$DeferId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'nId' = $NId
            'userId' = $UserId
            'email' = $Email
            'phone' = $Phone
            'ticket' = $Ticket
            'deferId' = $DeferId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/container/$CId/notification/$NId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Accept a proposal and turn it into an agent.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $PId
        The id of the proposal.
        
    #>
    function Set-ContainerProposal {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$PId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'pId' = $PId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/container/$CId/proposal/$PId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates a customer of your distributor. Nearly any property of the <code>GET /customer/:id</code> result object can be modified and send to the server.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $CompanyName
        The name of the customer.
        
        .PARAMETER $ZipCode
        The zip code of the customer.
        
        .PARAMETER $City
        The city of the customer.
        
        .PARAMETER $Country
        The country of the customer.
        
        .PARAMETER $Street
        The street of the customer.
        
        .PARAMETER $StreetNumber
        The street number of the customer.
        
        .PARAMETER $Email
        An email address of this customer.
        
        .PARAMETER $Phone
        A phone number of this customer.
        
        .PARAMETER $Language
        The default language for emails and other background translation for this customer.
        
        .PARAMETER $Timezone
        The timezone of this customer.
        
    #>
    function Set-Customer {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$CompanyName,
[Parameter(Mandatory=$false)]
$ZipCode,
[Parameter(Mandatory=$false)]
$City,
[Parameter(Mandatory=$false)]
$Country,
[Parameter(Mandatory=$false)]
$Street,
[Parameter(Mandatory=$false)]
$StreetNumber,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
[ValidateSet('en','de')]
$Language,
[Parameter(Mandatory=$false)]
$Timezone,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'companyName' = $CompanyName
            'zipCode' = $ZipCode
            'city' = $City
            'country' = $Country
            'street' = $Street
            'streetNumber' = $StreetNumber
            'email' = $Email
            'phone' = $Phone
            'language' = $Language
            'timezone' = $Timezone
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/$CId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates your customer's bucket.

    
        .PARAMETER $BId
        The id of the bucket.
        
        .PARAMETER $Name
        A describing name for the bucket.
        
    #>
    function Set-CustomerBucket {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'bId' = $BId
            'name' = $Name
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/bucket/$BId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add a user to the bucket.

    
        .PARAMETER $BId
        The id of the bucket.
        
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Set-CustomerBucketUser {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'bId' = $BId
            'uId' = $UId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/bucket/$BId/user/$UId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates your customer's deferred dispatch time.

    
        .PARAMETER $DtId
        The id of the dispatch time.
        
        .PARAMETER $Name
        A describing short name for the dispatch time.
        
        .PARAMETER $Defer
        How many minutes will the dispatch defer?
        
    #>
    function Set-CustomerDispatchtime {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$DtId,
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$Defer,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'dtId' = $DtId
            'name' = $Name
            'defer' = $Defer
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/dispatchTime/$DtId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Adds a user as manager to a customer.

    
        .PARAMETER $CId
        The customer id.
        
        .PARAMETER $Email
        What's the email address of the user you want to add? This address has to be registered as Server-Eye user.
        
    #>
    function Set-CustomerManager {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Email,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'email' = $Email
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/$CId/manager/$Email" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates settings of a customer. Nearly any parameter of <code>GET /customer/:cId/setting</code> is valid.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $TanssUrl
        The URL of an instance of TANSS.
        
        .PARAMETER $DefaultLanguage
        The language of this customers reports and other automatically generated stuff
        
        .PARAMETER $Timezone
        The timezone this customer is based.
        
    #>
    function Set-CustomerSetting {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$TanssUrl,
[Parameter(Mandatory=$false)]
[ValidateSet('de','en')]
$DefaultLanguage,
[Parameter(Mandatory=$false)]
$Timezone,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'tanssUrl' = $TanssUrl
            'defaultLanguage' = $DefaultLanguage
            'timezone' = $Timezone
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/$CId/setting" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates your customer's tag.

    
        .PARAMETER $TId
        The id of the tag.
        
        .PARAMETER $Name
        A describing name for the tag. Should be short and without spaces. Only 'A-Za-z0-9-.' allowed.
        
    #>
    function Set-CustomerTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$TId,
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'tId' = $TId
            'name' = $Name
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/tag/$TId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates your customer's view filter.

    
        .PARAMETER $VfId
        The id of the view filter.
        
        .PARAMETER $Name
        A describing name for the view filter.
        
        .PARAMETER $Query
        A query object the view filter executes on the view data. We use LokiJs syntax.
        
    #>
    function Set-CustomerViewfilter {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$VfId,
[Parameter(Mandatory=$false)]
$Name,
[Parameter(Mandatory=$false)]
$Query,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'vfId' = $VfId
            'name' = $Name
            'query' = $Query
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/customer/viewFilter/$VfId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Change a group.

    
        .PARAMETER $GId
        The id of the group.
        
        .PARAMETER $Name
        The name of the group.
        
    #>
    function Set-Group {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'gId' = $GId
            'name' = $Name
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/group/$GId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add a user to the group.

    
        .PARAMETER $GId
        The id of the group.
        
        .PARAMETER $UId
        The id of the user to add.
        
    #>
    function Set-GroupUser {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'gId' = $GId
            'uId' = $UId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/group/$GId/user/$UId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update an existing notification.

    
        .PARAMETER $NId
        The id of the notification.
        
        .PARAMETER $AId
        The id of the container or agent this notification belongs to.
        
        .PARAMETER $Mail
        Send an email as notification.
        
        .PARAMETER $Phone
        Send a phone text message as notification.
        
        .PARAMETER $Ticket
        Create a ticket as notification.
        
        .PARAMETER $DeferId
        Should this notification be triggered with defered dispatch? Pass an ID of a dispatchTime entry.
        
    #>
    function Set-MyNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$NId,
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$false)]
$Mail,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
$Ticket,
[Parameter(Mandatory=$false)]
$DeferId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'nId' = $NId
            'aId' = $AId
            'mail' = $Mail
            'phone' = $Phone
            'ticket' = $Ticket
            'deferId' = $DeferId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/me/notification/$NId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Change my password

    
        .PARAMETER $ValidationPassword
        The current password
        
        .PARAMETER $Password
        The desired new password. Must be at least 5 signs long.
        
        .PARAMETER $Passwordre
        Repeat of the desired password.
        
    #>
    function Set-MyPassword {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$ValidationPassword,
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$true)]
$Passwordre,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'validationPassword' = $ValidationPassword
            'password' = $Password
            'passwordre' = $Passwordre
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/me/password" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates settings of your user. Any parameter of <code>GET /me/setting</code> is valid.

    
    #>
    function Set-MySetting {
        [CmdletBinding()]
        Param(
            
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/me/setting" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update a report template and its included widgets.

    
        .PARAMETER $RtId
        The id of a report template.
        
        .PARAMETER $Name
        The name of the report template.
        
        .PARAMETER $Widgets
        The widgets that this report template contains.
        
    #>
    function Set-ReportingTemplate {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$RtId,
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$Widgets,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'rtId' = $RtId
            'name' = $Name
            'widgets' = $Widgets
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/reporting/template/$RtId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Change a user.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Prename
        The users' prename.
        
        .PARAMETER $Surname
        The users' surname.
        
        .PARAMETER $Email
        The users' email address. It has to be unique throughout Server-Eye.
        
        .PARAMETER $Roles
        The roles of the user.
        
        .PARAMETER $Phone
        The mobile phone number of the user. It is used to send mobile message notifications or reset the password.
        
    #>
    function Set-User {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$Prename,
[Parameter(Mandatory=$true)]
$Surname,
[Parameter(Mandatory=$true)]
$Email,
[Parameter(Mandatory=$false)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','mav','pcvisit','pm','powershell','reporting','rmm','tanss','tasks')]
$Roles,
[Parameter(Mandatory=$false)]
$Phone,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'prename' = $Prename
            'surname' = $Surname
            'email' = $Email
            'roles' = $Roles
            'phone' = $Phone
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add the users to a group.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $GId
        The id of the group.
        
    #>
    function Set-UserGroup {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$GId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'gId' = $GId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId/group/$GId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Set the roles of a user

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Roles
        The roles, that this user should have, as array
        
    #>
    function Set-UserRole {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','mav','pcvisit','pm','powershell','reporting','rmm','tanss','tasks')]
$Roles,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'roles' = $Roles
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId/role" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates settings of a user. Any parameter of <code>GET /user/:uId/setting</code> is valid.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Set-UserSetting {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId/setting" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates a setting of a user.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Key
        The setting that you want to modify.
        
        .PARAMETER $Value
        The new value of the setting.
        
    #>
    function Set-UserSettingKey {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
[ValidateSet('sendSummary','defaultNotifyEmail','defaultNotifyPhone','defaultNotifyTicket','timezone','theme')]
$Key,
[Parameter(Mandatory=$true)]
[ValidateSet('Boolean','Valid timezone','bright/dark/colorblind theme')]
$Value,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'key' = $Key
            'value' = $Value
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId/setting/$Key" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Is the user on vacation? You can set a user ID as substitude ID. All alerts will be redirected to that user.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $SubstitudeId
        The user ID of the substitude.
        
    #>
    function Set-UserSubstitude {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$SubstitudeId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'substitudeId' = $SubstitudeId
            }

            return Intern-PutJson -url "https://api.server-eye.de/2/user/$UId/substitude/$SubstitudeId" -authtoken $AuthToken -body $reqBody
        }
    }
    
    <#
    .SYNOPSIS
    Query the actionlog.

    
        .PARAMETER $Of
        A comma separated list of ids or an Array of ids. This can be any ids in any combination, e.g. id of a container or id of a user. You will receive the complete history behind any of these ids.
        
        .PARAMETER $Type
        A comma seperated list or an Array of types. You can reduce the result to specific change typess.
        
        .PARAMETER $ChangeKey
        The key which specifies the change
        
        .PARAMETER $NewValue
        The new value which is set for the made change
        
        .PARAMETER $OldValue
        The old value, which was set before the change was made
        
        .PARAMETER $Limit
        How many entries of the actionlog do you need in that timespan? Max value is 100.
        
        .PARAMETER $Start
        An utc date in milliseconds.
        
        .PARAMETER $End
        An utc date in milliseconds.
        
        .PARAMETER $MessageFormat
        If the entry should be human readable, specify the format of the message. This will include a 'message' property in each entry or not.
        
        .PARAMETER $IncludeRawData
        If the entry should contain the raw data. This includes the change object and additional information, if available, in each resulting entry.
        
    #>
    function Get-ActionlogList {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Of,
[Parameter(Mandatory=$false)]
$Type,
[Parameter(Mandatory=$false)]
$ChangeKey,
[Parameter(Mandatory=$false)]
$NewValue,
[Parameter(Mandatory=$false)]
$OldValue,
[Parameter(Mandatory=$false)]
$Limit,
[Parameter(Mandatory=$false)]
$Start,
[Parameter(Mandatory=$false)]
$End,
[Parameter(Mandatory=$false)]
[ValidateSet('none','md','html')]
$MessageFormat,
[Parameter(Mandatory=$false)]
$IncludeRawData,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'of' = $Of
            'type' = $Type
            'changeKey' = $ChangeKey
            'newValue' = $NewValue
            'oldValue' = $OldValue
            'limit' = $Limit
            'start' = $Start
            'end' = $End
            'messageFormat' = $MessageFormat
            'includeRawData' = $IncludeRawData
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/search/actionlog" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    The same as <code>GET /agent/:id/state</code>, but aId can be a comma seperated list or an array of agent ids. The result will be an object of state arrays with agent id as keys.

    
        .PARAMETER $AId
        The ids of the agents.
        
    #>
    function Get-AgentStateListbulk {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/state" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    The same as <code>GET /container/:id/proposal</code>, but id can be a comma seperated list or an array of container ids. The result will be an object of proposal arrays with container id as keys.

    
        .PARAMETER $CId
        The ids of the container.
        
    #>
    function Get-ContainerProposalListbulk {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/proposal" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    The same as <code>GET /container/:id/state</code>, but id can be a comma seperated list or an array of container ids. The result will be an object of state arrays with container id as keys.

    
        .PARAMETER $CId
        The ids of the container.
        
    #>
    function Get-ContainerStateListbulk {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/state" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create an agent.

    
        .PARAMETER $ParentId
        The id of the parent container.
        
        .PARAMETER $Type
        What type does the agent have? Use <code>GET /agent/type</code> to list all valid agent types.
        
        .PARAMETER $Name
        The name of the agent. If not set a matching default name will be used.
        
    #>
    function New-Agent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$ParentId,
[Parameter(Mandatory=$true)]
$Type,
[Parameter(Mandatory=$false)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'parentId' = $ParentId
            'type' = $Type
            'name' = $Name
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Copy an agent and all of its attributes.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $ParentId
        The id of the container that should host the copied agent.
        
    #>
    function New-AgentCopy {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$ParentId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'parentId' = $ParentId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/$AId/copy" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new note for an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $Message
        The note's message.
        
    #>
    function New-AgentNote {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$Message,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'message' = $Message
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/$AId/note" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new notification for an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $UserId
        The id of the user or group that should receive a notification.
        
        .PARAMETER $Email
        Send an email as notification.
        
        .PARAMETER $Phone
        Send a phone text message as notification.
        
        .PARAMETER $Ticket
        Create a ticket as notification.
        
        .PARAMETER $DeferId
        Should this notification be triggered with defered dispatch? Pass an ID of a dispatchTime entry.
        
    #>
    function New-AgentNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$UserId,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
$Ticket,
[Parameter(Mandatory=$false)]
$DeferId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'userId' = $UserId
            'email' = $Email
            'phone' = $Phone
            'ticket' = $Ticket
            'deferId' = $DeferId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/$AId/notification" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Write a hint for a state. Depending on the hint type the state is changed to working on, reopen, and so on.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $SId
        The id of the state.
        
        .PARAMETER $Author
        The user id or email address of the author of the hint. If not provided it's the session user.
        
        .PARAMETER $HintType
        The type of the hint.
        
        .PARAMETER $Message
        The message of the hint.
        
        .PARAMETER $AssignedUser
        The user that is assigned to this hint. e.g the user that is responsible to fix an alert.
        
        .PARAMETER $MentionedUsers
        The users that should receive an information mail. A comma seperated list or array of IDs or email addresses.
        
        .PARAMETER $Private
        Is this note only visible to the posters customer?
        
        .PARAMETER $Until
        If you are working on this state, until will you be working on it? unix timestamp millis.
        
    #>
    function New-AgentStateHint {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$SId,
[Parameter(Mandatory=$false)]
$Author,
[Parameter(Mandatory=$true)]
[ValidateSet('working','reopen','false alert','hint')]
$HintType,
[Parameter(Mandatory=$true)]
$Message,
[Parameter(Mandatory=$false)]
$AssignedUser,
[Parameter(Mandatory=$false)]
$MentionedUsers,
[Parameter(Mandatory=$false)]
$Private,
[Parameter(Mandatory=$false)]
$Until,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            'sId' = $SId
            'author' = $Author
            'hintType' = $HintType
            'message' = $Message
            'assignedUser' = $AssignedUser
            'mentionedUsers' = $MentionedUsers
            'private' = $Private
            'until' = $Until
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/$AId/state/$SId/hint" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates an API key for an user, customer or container.

    
        .PARAMETER $Email
        Email address of the user to login.
        
        .PARAMETER $Password
        Password of the user.
        
        .PARAMETER $Code
        If the user has two-factor enabled you have to send the 6-digit code during the auth process. The HTTP code 420 will tell you that two-factor is enabled.
        
        .PARAMETER $Name
        Give the key a name.
        
        .PARAMETER $Type
        What kind of key do you want?
        
        .PARAMETER $ValidUntil
        Do you want this key to expire?
        
        .PARAMETER $MaxUses
        Is this key meant to be used only a couple of times?
        
    #>
    function New-ApiKey {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Email,
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$false)]
$Code,
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$false)]
[ValidateSet('user','customer','container')]
$Type,
[Parameter(Mandatory=$false)]
$ValidUntil,
[Parameter(Mandatory=$false)]
$MaxUses,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'email' = $Email
            'password' = $Password
            'code' = $Code
            'name' = $Name
            'type' = $Type
            'validUntil' = $ValidUntil
            'maxUses' = $MaxUses
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/auth/key" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new note for a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $Message
        The note's message.
        
    #>
    function New-ContainerNote {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Message,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'message' = $Message
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/note" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new notification for a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $UserId
        The id of the user or group that should receive a notification.
        
        .PARAMETER $Email
        Send an email as notification.
        
        .PARAMETER $Phone
        Send a phone text message as notification.
        
        .PARAMETER $Ticket
        Create a ticket as notification.
        
        .PARAMETER $DeferId
        Should this notification be triggered with defered dispatch? Pass an ID of a dispatchTime entry.
        
    #>
    function New-ContainerNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$UserId,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
$Ticket,
[Parameter(Mandatory=$false)]
$DeferId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'userId' = $UserId
            'email' = $Email
            'phone' = $Phone
            'ticket' = $Ticket
            'deferId' = $DeferId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/notification" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Write a hint for a state. Depending on the hint type the state is changed to working on, reopen, and so on.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $SId
        The id of the state.
        
        .PARAMETER $Author
        The user id or email address of the author of the hint.
        
        .PARAMETER $HintType
        The type of the hint.
        
        .PARAMETER $Message
        The message of the hint.
        
        .PARAMETER $AssignedUser
        The user that is assigned to this hint. e.g the user that is responsible to fix an alert.
        
        .PARAMETER $MentionedUsers
        The users that should receive an information mail. A comma seperated list or array of IDs or email addresses.
        
        .PARAMETER $Private
        Is this note only visible to the posters customer?
        
        .PARAMETER $Until
        If you are working on this state, how long will it take? 0 for forever, 1 for one houer, 2 for two hours and so on.
        
    #>
    function New-ContainerStateHint {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$SId,
[Parameter(Mandatory=$true)]
$Author,
[Parameter(Mandatory=$true)]
[ValidateSet('working','reopen','false alert','hint')]
$HintType,
[Parameter(Mandatory=$true)]
$Message,
[Parameter(Mandatory=$false)]
$AssignedUser,
[Parameter(Mandatory=$false)]
$MentionedUsers,
[Parameter(Mandatory=$false)]
$Private,
[Parameter(Mandatory=$false)]
$Until,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'sId' = $SId
            'author' = $Author
            'hintType' = $HintType
            'message' = $Message
            'assignedUser' = $AssignedUser
            'mentionedUsers' = $MentionedUsers
            'private' = $Private
            'until' = $Until
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/state/$SId/hint" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates a new customer of your distributor. Nearly any property of the <code>GET /customer/:id</code> result object can be modified and send to the server.

    
        .PARAMETER $CompanyName
        The name of the customer.
        
        .PARAMETER $ZipCode
        The zip code of the customer.
        
        .PARAMETER $City
        The city of the customer.
        
        .PARAMETER $Country
        The country of the customer.
        
        .PARAMETER $Street
        The street of the customer.
        
        .PARAMETER $StreetNumber
        The street number of the customer.
        
        .PARAMETER $Email
        An email address of this customer.
        
        .PARAMETER $Phone
        A phone number of this customer.
        
        .PARAMETER $Language
        The default language for emails and other background translation for this customer.
        
        .PARAMETER $Timezone
        The timezone of this customer.
        
    #>
    function New-Customer {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CompanyName,
[Parameter(Mandatory=$true)]
$ZipCode,
[Parameter(Mandatory=$true)]
$City,
[Parameter(Mandatory=$true)]
$Country,
[Parameter(Mandatory=$false)]
$Street,
[Parameter(Mandatory=$false)]
$StreetNumber,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Phone,
[Parameter(Mandatory=$false)]
[ValidateSet('en','de')]
$Language,
[Parameter(Mandatory=$false)]
$Timezone,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'companyName' = $CompanyName
            'zipCode' = $ZipCode
            'city' = $City
            'country' = $Country
            'street' = $Street
            'streetNumber' = $StreetNumber
            'email' = $Email
            'phone' = $Phone
            'language' = $Language
            'timezone' = $Timezone
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates a bucket for your customer.

    
        .PARAMETER $Name
        A describing name for the bucket.
        
    #>
    function New-CustomerBucket {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'name' = $Name
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/bucket" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Uses a coupon for your customer

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $CouponCode
        The couponCode you want to use. Only 'A-Za-z0-9-._' allowed.
        
    #>
    function New-CustomerCoupon {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$CouponCode,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'couponCode' = $CouponCode
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/$CId/coupon" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates a deferred dispatch time for your customer.

    
        .PARAMETER $Name
        A describing short name for the dispatch time.
        
        .PARAMETER $Defer
        How many minutes will the dispatch defer?
        
    #>
    function New-CustomerDispatchtime {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$Defer,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'name' = $Name
            'defer' = $Defer
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/dispatchTime" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add a license to a customer.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Name
        The license that you want to add.
        
    #>
    function New-CustomerLicense {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
[ValidateSet('trayicon')]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'name' = $Name
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/$CId/license" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update a customers location.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Geo
        The customers new location.
        
        .PARAMETER $AddressObject
        The address of the customer.
        
    #>
    function New-CustomerLocation {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Geo,
[Parameter(Mandatory=$false)]
$AddressObject,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'geo' = $Geo
            'addressObject' = $AddressObject
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/$CId/location" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Updates a property of a customer.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Key
        The name of your custom property.
        
        .PARAMETER $Value
        The value of the property.
        
    #>
    function New-CustomerProperty {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Key,
[Parameter(Mandatory=$true)]
$Value,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'key' = $Key
            'value' = $Value
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/$CId/property" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates a tag for your customer.

    
        .PARAMETER $Name
        A describing name for the tag. Should be short and without spaces. Only 'A-Za-z0-9-.' allowed.
        
    #>
    function New-CustomerTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'name' = $Name
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/tag" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Creates a view filter for your customer.

    
        .PARAMETER $Name
        A describing name for the view filter.
        
        .PARAMETER $Query
        A query object the view filter executes on the view data. We use LokiJs syntax.
        
    #>
    function New-CustomerViewfilter {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$Query,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'name' = $Name
            'query' = $Query
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/customer/viewFilter" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a group.

    
        .PARAMETER $CustomerId
        The customer the new group should belong to.
        
        .PARAMETER $Name
        The name of the group.
        
    #>
    function New-Group {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'customerId' = $CustomerId
            'name' = $Name
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/group" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Validates the session und logs the user in by the given credentials.

    
        .PARAMETER $Email
        Email address of the user to login.
        
        .PARAMETER $Password
        Password of the user.
        
        .PARAMETER $Code
        If the user has two-factor enabled you have to send the 6-digit code during the auth process. The HTTP code 420 will tell you that two-factor is enabled.
        
        .PARAMETER $CreateApiKey
        Do you want to get an one time api key for this user?
        
        .PARAMETER $ApiKeyName
        If you want an api key, please give the baby a name.
        
    #>
    function New-Login {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
$Password,
[Parameter(Mandatory=$false)]
$Code,
[Parameter(Mandatory=$false)]
$CreateApiKey,
[Parameter(Mandatory=$false)]
$ApiKeyName,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'email' = $Email
            'password' = $Password
            'code' = $Code
            'createApiKey' = $CreateApiKey
            'apiKeyName' = $ApiKeyName
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/auth/login" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update your location.

    
        .PARAMETER $NoGeocoding
        If the given position should bo geocoded.
        
        .PARAMETER $Geo
        Your new location.
        
    #>
    function New-MyLocation {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$NoGeocoding,
[Parameter(Mandatory=$true)]
$Geo,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'noGeocoding' = $NoGeocoding
            'geo' = $Geo
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/me/location" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Register your device for mobile push notifications.

    
        .PARAMETER $Handle
        The Android, Firebase or iOS push handle.
        
        .PARAMETER $Type
        What kind of device do you want to register?
        
    #>
    function New-MyMobilepush {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Handle,
[Parameter(Mandatory=$true)]
[ValidateSet('GCM','FCM','APNS')]
$Type,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'handle' = $Handle
            'type' = $Type
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/me/mobilepush" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Enables two factor authentication for your user.

    
        .PARAMETER $Password
        Your Server-Eye account password.
        
        .PARAMETER $Code
        The 6 digit code of the authenticator app to validate the user and prove that you know the correct secret.
        
    #>
    function New-MyTwofactor {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$true)]
$Code,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'password' = $Password
            'code' = $Code
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/me/twofactor" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Install Server-Eye on a machine in that OCC Connector's network. Installation takes longer than this single request. The status of the installation job can be requestst using <code>GET /network/:customerId/:cId/system/installstatus</code>.

    
        .PARAMETER $CustomerId
        The id of the customer of the network.
        
        .PARAMETER $CId
        The id of the OCC Connector within the network.
        
        .PARAMETER $User
        The username of a user that has an administrative role on the container's operating system.
        
        .PARAMETER $Password
        The password of a user that has an administrative role on the container's operating system.
        
        .PARAMETER $Domain
        Does the user belong to a specific Windows domain?
        
        .PARAMETER $Host
        The host name of the system Server-Eye will be installed to. Should be a name retrived through <code>GET /network/:customerId/:cId/system</code>.
        
    #>
    function New-NetworkSystem {
        [CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUserNameAndPassWordParams", "")]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$User,
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$false)]
$Domain,
[Parameter(Mandatory=$true)]
$Host,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'customerId' = $CustomerId
            'cId' = $CId
            'user' = $User
            'password' = $Password
            'domain' = $Domain
            'host' = $Host
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/network/$CustomerId/$CId/system" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Install pcvisit on a container and start the remote agent service if not already started.

    
        .PARAMETER $CustomerId
        The id of the customer the container belongs to.
        
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $SupporterId
        Your pcvisit supporter ID.
        
        .PARAMETER $SupporterPassword
        Secure the remote access with a password.
        
        .PARAMETER $User
        The username of a user that has an administrative role on the container's operating system.
        
        .PARAMETER $Password
        The password of a user that has an administrative role on the container's operating system.
        
        .PARAMETER $Domain
        Does the user belong to a specific (windows) domain?
        
    #>
    function New-PcvisitStart {
        [CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUserNameAndPassWordParams", "")]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$SupporterId,
[Parameter(Mandatory=$true)]
$SupporterPassword,
[Parameter(Mandatory=$true)]
$User,
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$false)]
$Domain,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'customerId' = $CustomerId
            'cId' = $CId
            'supporterId' = $SupporterId
            'supporterPassword' = $SupporterPassword
            'user' = $User
            'password' = $Password
            'domain' = $Domain
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/pcvisit/$CustomerId/$CId/start" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Start a remote powershell session on a system.

    
        .PARAMETER $CustomerId
        The id of the customer the container belongs to.
        
        .PARAMETER $CId
        The id of the container.
        
    #>
    function New-PowershellStart {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'customerId' = $CustomerId
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/powershell/$CustomerId/$CId/start" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new report, which the Server-Eye backends generates as PDF files.

    
        .PARAMETER $CId
        The id of a customer.
        
        .PARAMETER $RtId
        The id of the report template.
        
        .PARAMETER $RepeatCron
        A unix cron that describes in which intervals the report will be generated. Note that time settings will be reset to midnight. A report can only be generated and send once a day.
        
        .PARAMETER $Recipients
        An array of user ids. Those users will receive the generated reports by email.
        
    #>
    function New-ReportingCustomReport {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$RtId,
[Parameter(Mandatory=$true)]
$RepeatCron,
[Parameter(Mandatory=$false)]
$Recipients,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'rtId' = $RtId
            'repeatCron' = $RepeatCron
            'recipients' = $Recipients
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/reporting/$CId/report" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a new report template with the included widgets.

    
        .PARAMETER $Name
        The name of the report template.
        
        .PARAMETER $Widgets
        The widgets that this report template contains.
        
    #>
    function New-ReportingTemplate {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$Widgets,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'name' = $Name
            'widgets' = $Widgets
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/reporting/template" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Reset a user's password.

    
        .PARAMETER $Email
        The mail address of the user.
        
        .PARAMETER $New_password
        The new password for the account.
        
        .PARAMETER $New_password_confirmation
        The confirmation of the new password.
        
        .PARAMETER $Code
        The code, which was created in step one.
        
    #>
    function New-Reset {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Email,
[Parameter(Mandatory=$true)]
$New_password,
[Parameter(Mandatory=$true)]
$New_password_confirmation,
[Parameter(Mandatory=$true)]
$Code,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'email' = $Email
            'new_password' = $New_password
            'new_password_confirmation' = $New_password_confirmation
            'code' = $Code
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/auth/reset" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Resets your secret key

    
        .PARAMETER $Password
        Your current password
        
    #>
    function New-ResetSecret {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Password,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'password' = $Password
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/me/setting/secret/reset" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Copy all agents of this container and pack them into one template.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function New-Template {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/template" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Create a user.

    
        .PARAMETER $CustomerId
        The customer the new user should belong to.
        
        .PARAMETER $Prename
        The users' prename.
        
        .PARAMETER $Surname
        The users' surname.
        
        .PARAMETER $Email
        The users' email address. It has to be unique throughout Server-Eye.
        
        .PARAMETER $Roles
        The roles of the user.
        
        .PARAMETER $Phone
        The mobile phone number of the user. It is used to send mobile message notifications or reset the password.
        
    #>
    function New-User {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CustomerId,
[Parameter(Mandatory=$true)]
$Prename,
[Parameter(Mandatory=$true)]
$Surname,
[Parameter(Mandatory=$false)]
$Email,
[Parameter(Mandatory=$false)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','mav','pcvisit','pm','powershell','reporting','rmm','tanss','tasks')]
$Roles,
[Parameter(Mandatory=$false)]
$Phone,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'customerId' = $CustomerId
            'prename' = $Prename
            'surname' = $Surname
            'email' = $Email
            'roles' = $Roles
            'phone' = $Phone
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/user" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Update a specific users location.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $NoGeocoding
        If the given position should bo geocoded.
        
        .PARAMETER $Geo
        The new location of the user.
        
    #>
    function New-UserLocation {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$NoGeocoding,
[Parameter(Mandatory=$true)]
$Geo,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'noGeocoding' = $NoGeocoding
            'geo' = $Geo
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/user/$UId/location" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Add a role to the user

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Role
        The name of the role, that should be added to this user
        
    #>
    function New-UserRole {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','reporting','pcvisit','pm','mav','powershell','tanss')]
$Role,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'uId' = $UId
            'role' = $Role
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/user/$UId/role/$Role" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Restart an agent

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Restart-Agent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'aId' = $AId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/agent/$AId/restart" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Restart a container

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Restart-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/restart" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Copy all agents of a template onto this container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $TId
        The id of the template.
        
    #>
    function Set-Template {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'tId' = $TId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/template/$TId" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Start a container

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Start-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/start" -authtoken $AuthToken -body $reqBody
        }
    }
    

    <#
    .SYNOPSIS
    Stop a container

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $Until
        Stop the container until a specific date. Send as date in milliseconds.
        
    #>
    function Stop-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$false)]
$Until,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            $reqBody = @{
            
            'cId' = $CId
            'until' = $Until
            }

            return Intern-PostJson -url "https://api.server-eye.de/2/container/$CId/stop" -authtoken $AuthToken -body $reqBody
        }
    }
    
    <#
    .SYNOPSIS
    Deletes an agent and all of its historical data.

    
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Remove-Agent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/agent/$AId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a specific note of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $NId
        The id of the note.
        
    #>
    function Remove-AgentNote {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$NId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/agent/$AId/note/$NId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a notification of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $NId
        The id of the notification.
        
    #>
    function Remove-AgentNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$NId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/agent/$AId/notification/$NId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a specific tag of an agent.

    
        .PARAMETER $AId
        The id of the agent.
        
        .PARAMETER $TId
        The id of the tag.
        
    #>
    function Remove-AgentTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$AId,
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/agent/$AId/tag/$TId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a container, all of its historical data and all its agents.

    
        .PARAMETER $CId
        The id of the container.
        
    #>
    function Remove-Container {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/container/$CId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a specific note of a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $NId
        The id of the note.
        
    #>
    function Remove-ContainerNote {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$NId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/container/$CId/note/$NId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a notification of a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $NId
        The id of the notification.
        
    #>
    function Remove-ContainerNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$NId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/container/$CId/notification/$NId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deny a proposal. Denied proposals will never show up again.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $PId
        The id of the proposal.
        
    #>
    function Remove-ContainerProposal {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$PId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/container/$CId/proposal/$PId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a specific tag of a container.

    
        .PARAMETER $CId
        The id of the container.
        
        .PARAMETER $TId
        The id of the tag.
        
    #>
    function Remove-ContainerTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/container/$CId/tag/$TId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Removes an api key.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Key
        The api key you want to delete.
        
    #>
    function Remove-CustomerApikey {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Key,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/$CId/apiKey/$Key" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a bucket of your customer.

    
        .PARAMETER $BId
        The id of the bucket.
        
    #>
    function Remove-CustomerBucket {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/bucket/$BId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Remove a user from the bucket.

    
        .PARAMETER $BId
        The id of the bucket.
        
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Remove-CustomerBucketUser {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$BId,
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/bucket/$BId/user/$UId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a deferred dispatch time of your customer.

    
        .PARAMETER $DtId
        The id of the dispatch time.
        
    #>
    function Remove-CustomerDispatchtime {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$DtId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/dispatchTime/$DtId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deactivate a license of a customer.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Name
        The name of the license that you want to deactivate.
        
    #>
    function Remove-CustomerLicense {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
[ValidateSet('trayicon')]
$Name,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/$CId/license/$Name" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Removes a manager from a user.

    
        .PARAMETER $CId
        The id of the managed customer.
        
        .PARAMETER $UId
        The id of the managing user.
        
    #>
    function Remove-CustomerManager {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/$CId/manager/$UId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a customer property.

    
        .PARAMETER $CId
        The id of the customer.
        
        .PARAMETER $Key
        The custom property that you want to delete.
        
    #>
    function Remove-CustomerProperty {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$Key,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/$CId/property/$Key" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a tag of your customer.

    
        .PARAMETER $TId
        The id of the tag.
        
    #>
    function Remove-CustomerTag {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/tag/$TId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a container template of your customer.

    
        .PARAMETER $TId
        The id of the template.
        
    #>
    function Remove-CustomerTemplate {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$TId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/template/$TId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes an agent from a container template of your customer.

    
        .PARAMETER $TId
        The id of the template.
        
        .PARAMETER $AId
        The id of the agent.
        
    #>
    function Remove-CustomerTemplateAgent {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$TId,
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/template/$TId/agent/$AId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a view filter of your customer.

    
        .PARAMETER $VfId
        The id of the view filter.
        
    #>
    function Remove-CustomerViewfilter {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$VfId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/customer/viewFilter/$VfId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a group.

    
        .PARAMETER $GId
        The id of the group.
        
    #>
    function Remove-Group {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/group/$GId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Remove a user from the group.

    
        .PARAMETER $GId
        The id of the group.
        
        .PARAMETER $UId
        The id of the user to remove.
        
    #>
    function Remove-GroupUser {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$GId,
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/group/$GId/user/$UId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes the push handle if you want to unsubscribe from mobile notifications.

    
        .PARAMETER $Handle
        The Android or iOS push handle.
        
    #>
    function Remove-MyMobilepush {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Handle,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/me/mobilepush/$Handle" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a notification of your user.

    
        .PARAMETER $NId
        The id of the notification.
        
        .PARAMETER $AId
        The id of the container or agent this notification belongs to.
        
    #>
    function Remove-MyNotification {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$NId,
[Parameter(Mandatory=$true)]
$AId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/me/notification/$NId?aId=$AId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Disable your user's two factor authentication and enable one factor authentication.

    
        .PARAMETER $Password
        Your Server-Eye account password.
        
        .PARAMETER $Code
        The 6 digit code of the authenticator app to validate the user.
        
    #>
    function Remove-MyTwofactor {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$Password,
[Parameter(Mandatory=$true)]
$Code,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/me/twofactor?password=$Password&code=$Code" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a report.

    
        .PARAMETER $CId
        The id of a customer.
        
        .PARAMETER $RId
        The id of a report of the customer.
        
    #>
    function Remove-ReportingCustomReport {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$CId,
[Parameter(Mandatory=$true)]
$RId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/reporting/$CId/report/$RId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Delete a report template and its widgets.

    
        .PARAMETER $RtId
        The id of a report template.
        
    #>
    function Remove-ReportingTemplate {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$RtId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/reporting/template/$RtId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Deletes a user.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Remove-User {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/user/$UId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Remove the user from a group.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $GId
        The id of the group.
        
    #>
    function Remove-UserGroup {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$GId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/user/$UId/group/$GId" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Remove a role of the user

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Role
        The name of the role, that should be deleted
        
    #>
    function Remove-UserRole {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
[ValidateSet('lead','installer','architect','techie','hr','hinter','reporting','pcvisit','pm','mav','powershell','tanss')]
$Role,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/user/$UId/role/$Role" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Remove the substitude of the user.

    
        .PARAMETER $UId
        The id of the user.
        
    #>
    function Remove-UserSubstitude {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/user/$UId/substitude" -authtoken $AuthToken
        }
    }
    

    <#
    .SYNOPSIS
    Disable a user's two factor authentication and enable one factor authentication.

    
        .PARAMETER $UId
        The id of the user.
        
        .PARAMETER $Password
        The Server-Eye account password of the logged in user / the user that correspondents to the api key.
        
    #>
    function Remove-UserTwofactor {
        [CmdletBinding()]
        Param(
            
[Parameter(Mandatory=$true)]
$UId,
[Parameter(Mandatory=$true)]
$Password,
            [Parameter(Mandatory=$true)]
            [alias("ApiKey","Session")]
            $AuthToken
        )
        
        
        Process {
            return Intern-DeleteJson -url "https://api.server-eye.de/2/user/$UId/twofactor?password=$Password" -authtoken $AuthToken
        }
    }
    