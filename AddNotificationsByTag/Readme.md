# AddNotificationsByCTag.ps1

Adds a notification to all agents with the specified Tag. 
Changes the notification if one notification for the User exist


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByTag/AddNotificationsByTag.ps1" -OutFile AddNotificationsByTag.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | AddNotificationsByTag.ps1 -Tag NameoftheTag -userId TheIdOfTheUser
```

## Call with API Key
```
AddNotificationsByTag.ps1 -apiKey yourApiKey -Tag NameoftheTag -userId TheIdOfTheUser
```

## Parameters

### apiKey
The api-Key of the user.

### tag
The Name of the Tag

### userId
The Id of the user who will receive the notification.

### email
Set if you want to receive an email

### phone
Set if you want to receive an SMS

### Ticket
Set if you want to create a Ticket

### deferid
The ID of the delay you want to set