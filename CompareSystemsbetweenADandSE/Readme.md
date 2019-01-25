# CompareSystemsbetweenADandSE.ps1

Compares System in the Active Directory and Server-Eye.
Checks if on all Systems is Server-Eye installed or if Server-Eye is installed on to many Systems.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/CompareSystemsbetweenADandSE/CompareSystemsbetweenADandSE.ps1" -OutFile CompareSystemsbetweenADandSE.ps1
```

## Call with Session via Connect-SESession and Active Directory Check
```
Connect-SESession | CompareSystemsbetweenADandSE.ps1 -CustomerID "ID of the Customer" -ADCheck
```

## Call with API Key and Active Directory Check
```
CompareSystemsbetweenADandSE.ps1 -apiKey yourApiKey -ADCheck
```

## Call with Session via Connect-SESession and Server-Eye Check
```
Connect-SESession | CompareSystemsbetweenADandSE.ps1 -CustomerID "ID of the Customer" -SECheck
```

## Call with API Key and Server-Eye Check
```
CompareSystemsbetweenADandSE.ps1 -apiKey yourApiKey -SECheck
```

## Parameters

### AuthToken
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

### CustomerID
ID of the Customer where you want to compare the Systemes.

### ADCheck
Checks the AD System if Server-Eye is installed.

### SECheck
Checks Server-Eye if all installed Systems are in the AD.

