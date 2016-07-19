# AddNotifications.ps1

Adds a notification to all agents of the specified customer. ATTENTION: Multiple executions of this script add multiple notifications to each agent.

## Call
```
AddNotifications.ps1 -apiKey yourApiKey -customerId TheIdOfTheCustomer -userId TheIdOfTheUser
```

## Parameters

### apiKey
The api-Key of the user.

### customerId
The id of the customer.

### userId
The Id of the user who will receive the notification.
