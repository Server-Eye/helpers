# NewSensorhubsLastXDays.ps1

Creates an excel file with a report of all Avira Sensors with status "Still not initialized" for all customers

## Call
```powershell
NewSensorhubsLastXDays.ps1 -authtoken "yourApiKey" -Days 10 -PathtoExcelfile ".\test.xlsx"
```

## Call with CustomerID
```powershell
NewSensorhubsLastXDays.ps1 -authtoken "yourApiKey" -Days 10 -PathtoExcelfile ".\test.xlsx" -customerID "CustomerID"
```

## Parameters

### Days
Show New Sensorhubs for the last Days.

### CustomerID
The Customer from where the Sensors should be shown

### PathtoExcelfile
Path were the Excel File should be created

### authtoken 
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell


