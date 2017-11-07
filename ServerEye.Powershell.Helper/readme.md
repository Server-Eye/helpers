# Server-Eye PowerShell Helper

This module provides easy access to the Server-Eye API. All API calls are supported. See https://api.server-eye.de/docs/2 for the corresponding cmdlet for each API function. 

## Namespaces
All functions for directly accessing the Server-Eye API are in the namespace ```SeApi```. 

#### Example
* Get-**SeApi**ContainerAgentList
* Get-**SeApi**Me

Those functions are direct representations of the Server-Eye REST API. 

Functions in the namespace ```SE``` make it easier to retrieve and edit objects. Those functions provide a more natural PowerShell look and feel. 

#### Example
* Get-**SE**Customer "MyCusto*"
* Connect-**SE**Session -Persist

Both namespaces are available after installing this module and can be used simultaneously.


## How to install
The module should be installed directly from the Microsoft Powershell Gallery (https://www.powershellgallery.com/).

If you are running PowerShell 5 or higher you can use the ```Install-Module``` command without further setup.  

If you use PowerShell 3 or 4, please follow the instructions at http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409 to install the required extension.

Now install the Module:
```powershell
Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser
``` 

## How to use the module
The module provides functions to interact with the Server-Eye API. Authentication can be done via login or api key. 

### Load the Module
Before you can use the module in your scripts it has to be loaded. Either manually by you or automatically.
```powershell
# Manual import
Import-Module -Name ServerEye.Powershell.Helper
```


### API Key
You can call the Get functions directly with an API key. A login is not needed.
```powershell
Get-SeApiMyNodesList -ApiKey "123-456-ABC-DEF"
```

### Login with Username and Password
API keys should only be used in automated processes. Using an API key in an interactive console session is not advised. 

In those situations you can use a Server-Eye session to authenticate yourself.
```powershell
$session = Connect-SESession
# This will ask you for username and password
Get-SeApiMyNodesList -Session $session
Get-SeApiMe -Session $session

```

It is possible to save the current session in the active PowerShell session. Calls to functions in the SE namespace will read the session stored in the PowerShell.
```powershell
Connect-SESession -Persist
# This will ask you for username and password

# The session does not need to be passed to the cmdlet
Get-SECustomer "Systemmanger IT"

```


### Logout
If the session was saved in a variable, you should destroy the session when you are done.
```powershell
# Disconnect an explicit session
Disconnect-SESession -Session $session

# Disconnect the global session
Disconnect-SESession
```

### Available Cmdlets
#### SE Namespace
* Connect-SESession
* Disconnect-SESession
* Get-SECustomer
* Get-SENotification
* Get-SESensor
* Get-SESensorState
* Get-SESensorSetting
+ Set-SESensorSetting
* Get-SESensorhub
* Restart-SESensorhub
* New-SENotification

#### SeApi Namespace
* Get-SeApiActionlogList
* Get-SeApiAgent
* Get-SeApiAgentActionlogList
* Get-SeApiAgentCategoryList
* Get-SeApiAgentChart
* Get-SeApiAgentNoteList
* Get-SeApiAgentNotificationList
* Get-SeApiAgentRemoteSetting
* Get-SeApiAgentSettingList
* Get-SeApiAgentStateList
* Get-SeApiAgentStateListbulk
* Get-SeApiAgentTagList
* Get-SeApiAgentTypeList
* Get-SeApiAgentTypeSettingList
* Get-SeApiContainer
* Get-SeApiContainerActionlogList
* Get-SeApiContainerAgentList
* Get-SeApiContainerInventory
* Get-SeApiContainerNoteList
* Get-SeApiContainerNotificationList
* Get-SeApiContainerProposalList
* Get-SeApiContainerProposalSettingList
* Get-SeApiContainerStateList
* Get-SeApiContainerStateListbulk
* Get-SeApiContainerTagList
* Get-SeApiCustomer
* Get-SeApiCustomerApikey
* Get-SeApiCustomerApikeyList
* Get-SeApiCustomerBucketList
* Get-SeApiCustomerBucketUserList
* Get-SeApiCustomerContainerList
* Get-SeApiCustomerDispatchtimeList
* Get-SeApiCustomerList
* Get-SeApiCustomerLocation
* Get-SeApiCustomerManagerList
* Get-SeApiCustomerSettingList
* Get-SeApiCustomerTagList
* Get-SeApiCustomerTemplateAgentList
* Get-SeApiCustomerTemplateList
* Get-SeApiCustomerUsage
* Get-SeApiCustomerUsageList
* Get-SeApiCustomerViewfilterList
* Get-SeApiGroup
* Get-SeApiGroupList
* Get-SeApiGroupUserList
* Get-SeApiKey
* Get-SeApiMe
* Get-SeApiMyCustomer
* Get-SeApiMyFeedList
* Get-SeApiMyLocation
* Get-SeApiMyMobilepush
* Get-SeApiMyMobilepushList
* Get-SeApiMyNodesList
* Get-SeApiMyNotificationList
* Get-SeApiMySetting
* Get-SeApiMyTwofactor
* Get-SeApiMyTwofactorSecret
* Get-SeApiNetworkSystemInstallstatusList
* Get-SeApiNetworkSystemList
* Get-SeApiPcvisit
* Get-SeApiPcvisitCheck
* Get-SeApiReportingCustomReport
* Get-SeApiReportingCustomReportList
* Get-SeApiReportingTemplate
* Get-SeApiReportingTemplateList
* Get-SeApiRoleList
* Get-SeApiUser
* Get-SeApiUserGroupList
* Get-SeApiUserList
* Get-SeApiUserLocation
* Get-SeApiUserSettingList
* New-SeApiAgent
* New-SeApiAgentCopy
* New-SeApiAgentNote
* New-SeApiAgentNotification
* New-SeApiAgentStateHint
* New-SeApiAgentTag
* New-SeApiApiKey
* New-SeApiContainerNote
* New-SeApiContainerNotification
* New-SeApiContainerStateHint
* New-SeApiContainerTag
* New-SeApiCustomer
* New-SeApiCustomerBucket
* New-SeApiCustomerCoupon
* New-SeApiCustomerDispatchtime
* New-SeApiCustomerLocation
* New-SeApiCustomerTag
* New-SeApiCustomerViewfilter
* New-SeApiGroup
* New-SeApiLogin
* New-SeApiLogout
* New-SeApiMyLocation
* New-SeApiMyMobilepush
* New-SeApiMyTwofactor
* New-SeApiNetworkSystem
* New-SeApiPcivistStart
* New-SeApiReportingCustomReport
* New-SeApiReportingTemplate
* New-SeApiReset
* New-SeApiTemplate
* New-SeApiUser
* New-SeApiUserLocation
* Read-SeApiCustomerBucket
* Remove-SeApiAgent
* Remove-SeApiAgentNote
* Remove-SeApiAgentNotification
* Remove-SeApiAgentTag
* Remove-SeApiContainer
* Remove-SeApiContainerNote
* Remove-SeApiContainerNotification
* Remove-SeApiContainerProposal
* Remove-SeApiContainerTag
* Remove-SeApiCustomerApikey
* Remove-SeApiCustomerBucket
* Remove-SeApiCustomerBucketUser
* Remove-SeApiCustomerDispatchtime
* Remove-SeApiCustomerManager
* Remove-SeApiCustomerTag
* Remove-SeApiCustomerTemplate
* Remove-SeApiCustomerTemplateAgent
* Remove-SeApiCustomerViewfilter
* Remove-SeApiGroup
* Remove-SeApiGroupUser
* Remove-SeApiMyMobilepush
* Remove-SeApiMyNotification
* Remove-SeApiMyTwofactor
* Remove-SeApiReportingCustomReport
* Remove-SeApiReportingTemplate
* Remove-SeApiUser
* Remove-SeApiUserGroup
* Remove-SeApiUserSubstitude
* Remove-SeApiUserTwofactor
* Restart-SeApiContainer
* Set-SeApiAgent
* Set-SeApiAgentNotification
* Set-SeApiAgentSetting
* Set-SeApiContainer
* Set-SeApiContainerNotification
* Set-SeApiContainerProposal
* Set-SeApiCustomer
* Set-SeApiCustomerBucket
* Set-SeApiCustomerBucketUser
* Set-SeApiCustomerDispatchtime
* Set-SeApiCustomerManager
* Set-SeApiCustomerSetting
* Set-SeApiCustomerTag
* Set-SeApiCustomerViewfilter
* Set-SeApiGroup
* Set-SeApiGroupUser
* Set-SeApiMyNotification
* Set-SeApiMySetting
* Set-SeApiReportingTemplate
* Set-SeApiTemplate
* Set-SeApiUser
* Set-SeApiUserGroup
* Set-SeApiUserSetting
* Set-SeApiUserSettingKey
* Set-SeApiUserSubstitude
* Start-SeApiContainer
* Stop-SeApiContainer