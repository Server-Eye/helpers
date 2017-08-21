# Server-Eye PowerShell Helper

This module provides easy access to the Server-Eye API. All API calls are supported. See https://api.server-eye.de/docs/2 for the corresponding cmdlet for each API function. 

## How to install
The module should be installed directly from the Microsoft Powershell Gallery (https://www.powershellgallery.com/).

If you are running PowerShell 5 or higher you can use the ```Install-Module``` command without further setup.  

If you use PowerShell 3 or 4, please follow the instructions at http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409 to install the required extension.

Now install the Module:
```powershell
Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser
``` 

## How to use the module
The module provides functions to interact with the Server-Eye API. Authentication can be done via login or api key. 

### Load the Module
Before you can use the module in your scripts it has to be loaded. Either manually by you or automatically.
```powershell
# Manual import
Import-Module -Name ServerEye.Powershell.Helper
```


### API Key
You can call the Get functions directly with an API key. A login is not needed.
```powershell
Get-SeApiMyNodesList -ApiKey "123-456-ABC-DEF"
```

### Login with Username and Password
API keys should only be used in automated processes. Using an API key in an interactive console session is not advised. 

In those situations you can use a Server-Eye session to authenticate yourself.
```powershell
$session = Connect-SESession
# This will ask you for username and password
Get-SeApiMyNodesList -Session $session
Get-SeApiMe -Session $session

```

### Logout
If the session was saved in a variable, you should destroy the session when you are done.
```powershell
Disconnect-SESession -Session $session
```

