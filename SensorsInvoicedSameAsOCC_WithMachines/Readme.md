# SensorsInvoicedSameAsOCC_WithMachines.ps1

Creates an excel file with a report of all invoiced sensors of all customers. Also the servers and workstation are counted for each customer.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/SensorsInvoicedSameAsOCC_WithMachines/SensorsInvoicedSameAsOCC_WithMachines.ps1" -OutFile SensorsInvoicedSameAsOCC_WithMachines.ps1
```
## Call with APIKey
```
SensorsInvoicedSameAsOCC_WithMachines.ps1 -apiKey yourApiKey -year theYearForTheReport -month theMonthForTheReport
```

## Call with Connect-SESession
```
Connect-SESession | SensorsInvoicedSameAsOCC_WithMachines.ps1 -apiKey yourApiKey -year theYearForTheReport -month theMonthForTheReport
```

## Parameters

### apiKey
The api-Key of the user.

### year
The year for which the report is created.

### month
The month for which the report is created.