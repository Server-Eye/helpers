# ContainerInventory.ps1

Creates an excel file with a report of the inventory of each sensorhub of each customer or a specific customer.

Displayed Values:
Kunde	
OCC-Connector	
Sensorhub	
CPU	
RAM	
HDD Name	
HDD Kap.	
HDD Free	
System	
Betriebssystem	
Betriebssystem-Key	
Office Version
Office-Key

### With an API Key
```powershell
ContainerInventory.ps1 -apiKey "yourApiKey" [-custID "specificCustomerID"]
```

### Via Login
```powershell
Connect-SESession | ContainerInventory.ps1 [-custID "specificCustomerID"]
```

### With an API Key
```powershell
ProgrammInventory.ps1 -apiKey "yourApiKey" [-custID "specificCustomerID"]
```

### Via Login
```powershell
Connect-SESession | ProgrammInventory.ps1 [-custID "specificCustomerID"]
```

## Parameters

### apiKey
The api-Key of the user.

### custID
Optional Parameter. The ID of the customer. If you want to create the report only for a specific customer then you can use the paramter custID.
