# SetSystemUserProxy.ps1

Probes for possible proxies configured in $proxyArray to fit your environment

## Call
```
SetSystemUserProxy.ps1
```

## HowTo
   How to add possible proxys to probe for in your environment
   add a member to $proxyArray (see below)
   Syntax = ("ProxyURL:ProxyPort")

   $proxyArray = @(
    <#
    for example ("IP/Name of the Proxy:Proxy Port")
    ("10.50.2.30:8080"),
    ("proxy.services.datevnet.de:8880"),
    ("192.168.71.240":8080")
    #>
   
)

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/SetSystemUserProxy/SetSystemUserProxy.ps1" -OutFile SetSystemUserProxy.ps1
```


