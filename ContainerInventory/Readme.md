# ContainerInventory.ps1

This script has been deprecated. 

Please use the Helper function ```Get-SEInventory``` instead. 

# ProgrammInventory.ps1

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/ContainerInventory/ProgrammInventory.ps1" -OutFile ProgrammInventory.ps1
```

### With an API Key
```powershell
ProgrammInventory.ps1 -apiKey "yourApiKey" -custID "specificCustomerID"
```

### Via Login
```powershell
Connect-SESession | ProgrammInventory.ps1 -custID "specificCustomerID"
```

### When Export to Excel use this Call
```powershell
.\ProgrammInventory.ps1 -custID "specificCustomerID" | Select-Object Sensorhub,Software | Select-Object -Property Sensorhub -ExpandProperty Software | Export-Excel -Path "Filename or Path "-AutoSize -NoNumberConversion Version
```

## Parameters

### apiKey
The api-Key of the user.

### custID
Optional Parameter. The ID of the customer. If you want to create the report only for a specific customer then you can use the paramter custID.
