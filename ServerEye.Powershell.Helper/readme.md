# Server-Eye PowerShell Helper

This module provides easy access to the Server-Eye API. Right now, not all features of the API are present but we plan to have a complete coverage as soon as possible.

## How to install
The module should be installed directly from the Microsoft Powershell Gallery (https://www.powershellgallery.com/).

If you are running PowerShell 5 or higer you can use the ```Install-Module``` command without further setup.  

If you use PowerShell 3 or 4, please follow the instructions at http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409 to install the needed Extension.

Now install the Module:
```powershell
Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser
``` 

## How to use the module
The module provides functions to interact with the Server-Eye API. Authentication can be done via login or api key. 

### Load the Module
Before you can use the module in your scripts it has to be loaded. Either manually by you or automaticly in your script.
```powershell
Import-Module -Name ServerEye.Powershell.Helper
```

### API Key
You can call the Get functions directly with an API key. A login is not needed.
```powershell
Get-VisibleCustomer -ApiKey "123-456-ABC-DEF"
```

### Login with Username and Password
API keys should only be used in automated processes. Using an API key in an interactive console session is not advised. 

In those situations you can use a Server-Eye session to authenticate yourself.
```powershell
$session = Connect-ServerEyeSession
# This will ask you for username and password
Get-VisibleCustomer -Session $session
```

