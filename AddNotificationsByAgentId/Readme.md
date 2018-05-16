# AddNotificationsByAgentId.ps1

Adds a notification to all customers with the specified agent id.

Changes the notification if one notification for the User exist


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByAgentId/AddNotificationsByAgentId.ps1" -OutFile AddNotificationsByAgentId.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | AddNotificationsByAgentId.ps1 -userId TheIdOfTheUser -subtypeOfAgent theIdOfTheAgentType
```

## Call with API Key
```
AddNotificationsByAgentId.ps1 -apiKey yourApiKey -userId TheIdOfTheUser -subtypeOfAgent theIdOfTheAgentType
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell.

### userId
The Id of the user who will receive the notification.

### subtypeOfAgent
The Id of the agent-type to which you want to add the notification

### email
Set if you want to receive an email

### phone
Set if you want to receive an SMS

### Ticket
Set if you want to create a Ticket

### deferid
The ID of the delay you want to set