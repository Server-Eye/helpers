# AddNotificationsByCustomerAndAgentId.ps1

Adds a notification to all agents of the specified customer AND specified by the agent id.
Changes the notification if one notification for the User exist

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByCustomerAndAgentId/AddNotificationsByCustomerAndAgentId.ps1" -OutFile AddNotificationsByCustomerAndAgentId.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | AddNotificationsByCustomerAndAgentId.ps1 -customerId TheIdOfTheCustomer -userId TheIdOfTheUser -AgentType theIdOfTheAgentType
```

## Call with API Key
```
AddNotificationsByCustomerAndAgentId.ps1 -apiKey yourApiKey -customerId TheIdOfTheCustomer -userId TheIdOfTheUser -AgentType theIdOfTheAgentType
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### customerId
The id of the customer.

### userId
The Id of the user who will receive the notification.

### AgentType
The Id of the agent-type to which you want to add the notification

### email
Set if you want to receive an email

### phone
Set if you want to receive an SMS

### Ticket
Set if you want to create a Ticket

### deferid
The ID of the delay you want to set