# AddNotificationsByCustomer.ps1

Adds a notification to all agents of the the specified customers.

Changes the notification if one notification for the User exist


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotificationsByCustomer/AddNotificationsByCustomer.ps1" -OutFile AddNotificationsByCustomer.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | AddNotificationsByCustomer.ps1 -customerId TheIdOfTheCustomer -userId TheIdOfTheUser 
```

## Call with API Key
```
AddNotificationsByCustomer.ps1 -apiKey yourApiKey -customerId TheIdOfTheCustomer -userId TheIdOfTheUser 
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### customerId
The id of the customer.

### userId
The Id of the user who will receive the notification.

### email
Set if you want to receive an email

### phone
Set if you want to receive an SMS

### ticket
Set if you want to create a Ticket

### deferid
The ID of the delay you want to set
