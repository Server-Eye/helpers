# AddNotificationsByAgentId.ps1

Adds a notification to all agents of the specified customer AND specified by the agent id.


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByAgentId/AddNotificationsByAgentId.ps1" -OutFile AddNotificationsByAgentId.ps1
```

## Call
```
AddNotificationsByAgentId.ps1 -apiKey yourApiKey -userId TheIdOfTheUser -subtypeOfAgent theIdOfTheAgentType
```

## Parameters

### apiKey
The api-Key of the user.

### userId
The Id of the user who will receive the notification.

### subtypeOfAgent
The Id of the agent-type to which you want to add the notification