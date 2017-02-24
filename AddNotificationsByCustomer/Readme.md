# AddNotificationsByCustomer.ps1

Adds a notification to all agents of the specified customer AND specified by the agent id. ATTENTION: Multiple executions of this script will add multiple notifications to each agent.


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByCustomer/AddNotificationsByCustomer.ps1" -OutFile AddNotificationsByCustomer.ps1
```

## Call
```
AddNotificationsByCustomer.ps1 -apiKey yourApiKey -customerId TheIdOfTheCustomer -userId TheIdOfTheUser 
```

## Parameters

### apiKey
The api-Key of the user.

### customerId
The id of the customer.

### userId
The Id of the user who will receive the notification.
