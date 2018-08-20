<#
.Synopsis
   SetSystemUserProxy-v3.ps1 - This script sets a Proxy for the local SYSTEM user
    Author: Lukas Raunheimer, nexcon-it GmbH; lr@nexcon-it.de
.DESCRIPTION
   Setting a Proxy for the local SYSTEM user is necessary for Server Eye
   Patch Management in environments using a web proxy
   -> always run SetSystemUserProxy-v3.ps1 with administrative privileges
.EXAMPLE
 
.INPUTS
   none
.NOTES
 
.FUNCTIONALITY
   Probes for possible proxies configured in $proxyArray to fit your environment
 
   How to add possible proxys to probe for in your environment
   add a member to $proxyArray (see below)
   Syntax = @("ProxyURL",ProxyPort)
#>
 
$ErrorActionPreference = "Stop"
 
$proxyArray = @(

    <#
    for example @("IP/Name of the Proxy","Proxy Port")
    @("10.50.2.30",8080),
    @("proxy.services.datevnet.de",8880),
    @("192.168.71.240",8080)
    #>
   
)
 
Function OSWeiche() {
    [version]$OSVersion = [Environment]::OSVersion.Version
    If ($OSVersion -gt "10.0") {
        Write-Host -ForegroundColor Yellow 'Info: Win 10/Server 2016 ermittelt.'
        $global:useTestNetConnection = $true
    } ElseIf ($OSVersion -gt "6.3") {
        Write-Host -ForegroundColor Yellow 'Info: Win 8.1/Server 2012R2 ermittelt.'
        $global:useTestNetConnection = $true
    } ElseIf ($OSVersion -gt "6.2") {
        Write-Host -ForegroundColor Yellow 'Info: Win 8/Server 2012 ermittelt.'
        $global:useTestNetConnection = $true
    } ElseIf ($OSVersion -gt "6.1") {
        Write-Host -ForegroundColor Yellow 'Info: Win 7/Server 2008 R2 ermittelt.'
        $global:useTestNetConnection = $false
    } Else {
        Write-Host -ForegroundColor Red 'Fehler: Vista oder schlechter gefunden, breche ab!'
        exit 0
    }
}
 
Function FindAndSetProxy() {
 
    foreach ($proxy in $proxyArray) {
        $proxyURL=$proxy[0]
        $proxyPort=$proxy[1]
        Write-Host -ForegroundColor Yellow "Info: Suche nach Proxy" $proxyURL "mit Port" $proxyPort"."
 
        If (!$useTestNetConnection) {
            If ((Test-Connection -ComputerName $proxyURL -Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) -eq $true) {
                SetSystemUserProxy
            }
        }
 
        If ($useTestNetConnection) {
            If ((Test-NetConnection -ComputerName $proxyURL -Port $proxyPort -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) -eq $true) {
                SetSystemUserProxy
            }
        }
    }
 
    Write-Host -ForegroundColor Red "Kein Proxy erreichbar, breche ab!"; exit 0
}
 
Function SetSystemUserProxy() {
    Write-Host -ForegroundColor Green "Info: Proxy" $proxyURL "mit Port" $proxyPort "gefunden."
    Write-Host -ForegroundColor Green "Info: Ermittle Proxy-Ausnahmen des aktuellen Users."
 
    $ProxyOverride = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\' -Name ProxyOverride).ProxyOverride
 
    Write-Host -ForegroundColor Green "Info: Proxy-Ausnahmen gefunden:" $ProxyOverride
 
    $currentProxy = $proxyURL + ":" + $proxyPort
    bitsadmin.exe /util /setieproxy localsystem MANUAL_PROXY $currentProxy $ProxyOverride
 
    Write-Host -ForegroundColor Green "Proxy" $currentProxy "mit Ausnahmen" $ProxyOverride "wurde erfolgreich gesetzt."
    exit 0
}
 
OSWeiche
FindAndSetProxy
