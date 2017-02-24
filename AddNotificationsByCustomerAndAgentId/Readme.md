# AddNotificationsByCustomerAndAgentId.ps1

Adds a notification to all agents of the specified customer AND specified by the agent id. ATTENTION: Multiple executions of this script will add multiple notifications to each agent.


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByCustomerAndAgentId/AddNotificationsByCustomerAndAgentId.ps1" -OutFile AddNotificationsByCustomerAndAgentId.ps1
```

## Call
```
AddNotificationsByCustomerAndAgentId.ps1 -apiKey yourApiKey -customerId TheIdOfTheCustomer -userId TheIdOfTheUser -subtypeOfAgent theIdOfTheAgentType
```

## Parameters

### apiKey
The api-Key of the user.

### customerId
The id of the customer.

### userId
The Id of the user who will receive the notification.

### subtypeOfAgent
The Id of the agent-type to which you want to add the notification