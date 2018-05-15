# AddNotificationsByAgentId.ps1

Adds a notification to agents of the all customers with the specified agent id.
Changes the notification if on for the User exist


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

### email
Set if you want to receive an email

### phone
Set if you want to receive an SMS

### Ticket
Set if you want to create a Ticket

### deferid
The ID of the delay you want to set