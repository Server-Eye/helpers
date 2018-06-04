# AddNotesToAgentByAgendID.ps1

This script will add a Note to an all specified Agent based on the AgentType. The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNotesToAgentByAgendID.ps1" -OutFile AddNotesToAgentByAgendID.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNotesToAgentByAgendID.ps1 -ApiKey "yourApiKey" -Agenttype "IDofTheAgentType" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNotesToAgentByAgendID.ps1 -Agenttype "IDofTheAgentType" -Message "The Message you want to add"
```


# AddNotesToAgentByCustomerID.ps1

This script will add a Note to an Agent based on the Customer.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNotesToAgentByCustomerID.ps1" -OutFile AddNotesToAgentByCustomerID.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNotesToAgentByCustomerID.ps1 -ApiKey "yourApiKey" -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNotesToAgentByCustomerID.ps1 -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

# AddNotesToAgentByCustomerIDandAgentID.ps1

This script will add a Note to an Agent based on the Customer and the AgentType.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNotesToAgentByCustomerIDandAgentID.ps1" -OutFile AddNotesToAgentByCustomerIDandAgentID.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNotesToAgentByCustomerIDandAgentID.ps1 -ApiKey "yourApiKey" -Agenttype "IDofTheAgentType" -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNotesToAgentByCustomerIDandAgentID.ps1 -Agenttype "IDofTheAgentType" -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```


# AddNoteToContainerByCustomerID.ps1

This script will add a Note to all Container for this Customer.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNoteToContainerByCustomerID.ps1" -OutFile AddNoteToContainerByCustomerID.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNoteToContainerByCustomerID.ps1 -ApiKey "yourApiKey" -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNoteToContainerByCustomerID.ps1 -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

# AddNoteToContainerByServerName.ps1

This script will add a Note to all Container with the ServerName. The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNoteToContainerByServerName.ps1" -OutFile AddNoteToContainerByServerName.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNoteToContainerByServerName.ps1 -ApiKey "yourApiKey" -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNoteToContainerByServerName.ps1 -CustomerID "IDofTheCustomer" -Message "The Message you want to add"
```

# AddNoteToContainerByTag.ps1

This script will add a Note to an Container based on the Tag.. The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/AddNotes/AddNoteToContainerByTag.ps1" -OutFile AddNoteToContainerByTag.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
AddNoteToContainerByTag.ps1 -ApiKey "yourApiKey" -Tag "NameOfTheTag" -Message "The Message you want to add"
```

### Via Login
```powershell
Connect-SESession | AddNoteToContainerByTag.ps1 -Tag "NameOfTheTag" -Message "The Message you want to add"
```