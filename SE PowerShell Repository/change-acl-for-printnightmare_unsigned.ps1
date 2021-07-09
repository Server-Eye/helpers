#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Change ACL for Printnightmare
        
    .DESCRIPTION
        Will restriced access to the Spooler for the System User

    .PARAMETER SetACL
    1 to restrict the System User, 0 remove the restriction, default is 0

    .PARAMETER StopSpooler
    1 to stop and disable the Spooler Service, 0 to Start the Spooler Service, default is 0
    Disabling the Print Spooler service disables the ability to print both locally and remotely.

    .PARAMETER DisableRemotePrint
    1 Disable inbound remote printing, 0 to not change a thing, default is 0
    Impact of workaround This policy will block the remote attack vector by preventing inbound remote printing operations. The system will no longer function as a print server, but local printing to a directly attached device will still be possible.
    

    .NOTES
        Author  : Server-Eye,Krämer IT Solutions GmbH
        Version : 1.0

    .Link
    https://blog.truesec.com/2021/06/30/fix-for-printnightmare-cve-2021-1675-exploit-to-keep-your-print-servers-running-while-a-patch-is-not-available/ 
    https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527
#>

<#
<version>2</version>
<description>Checks the given Services an will restart them when necessary</description>
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet(0, 1)]
    [int]$SetACL = 0,
    [Parameter(Mandatory = $false)]
    [ValidateSet(0, 1)]
    [int]$StopSpooler = 0,
    [Parameter(Mandatory = $false)]
    [ValidateSet(0, 1)]
    [int]$DisableRemotePrint = 0
)

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("System", "Modify", "ContainerInherit, ObjectInherit", "None", "Deny")
$Path = "C:\Windows\System32\spool\drivers"
$PrintPath = "HKLM:\Software\Policies\Microsoft\Windows NT\"
$RemotePrintPath = "Printers"
$RemotePrintName = "RegisterSpoolerRemoteRpcEndPoint"
$RemotePrintType = "DWORD"
$RemotePrintEnable = 1
$RemotePrintDisable = 2
#load the libraries from the Server Eye directory
$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

#Define the exit Code
$exitCode = -1
$Spooler = Get-Service -Name Spooler
$Acl = (Get-Item $Path).GetAccessControl('Access')
$DenyACL = $Acl.Access | Where-Object { ($_.IdentityReference -eq "NT-AUTORITÄT\SYSTEM") -and ($_.FileSystemRights -eq "Modify") -and ($_.AccessControlType -eq "deny") }
$state = Get-ItemProperty -Path (Join-Path -Path $PrintPath -ChildPath $RemotePrintPath) -Name $RemotePrintName

try {
    if ($StopSpooler -eq 0) {
        if ($Spooler.StartType -eq "Disabled") {
            Set-Service -Name Spooler -StartupType Automatic
            Start-Service $Spooler
            $msg.AppendLine("`nSpooler was set to automatic and started`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        else {
            $msg.AppendLine("`nSpooler was already set to the desired state (Automatic).`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
    }
    if ($StopSpooler -eq 1) {
        if ($Spooler.StartType -eq "Automatic") {
            Stop-Service $Spooler -Force
            Set-Service -Name Spooler -StartupType Disabled
            $msg.AppendLine("`nSpooler was set to disabled and stopped.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        else {
            $msg.AppendLine("`nSpooler was already set to the desired state (disabled).`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
    }
    if ($DisableRemotePrint -eq 1) {
        if (!$state) {
            New-Item -Path $PrintPath -Name $RemotePrintPath
            New-ItemProperty -Path (Join-Path -Path $PrintPath -ChildPath $RemotePrintPath) -Name $RemotePrintName -PropertyType $RemotePrintType -Value $RemotePrintDisable -Force
            Restart-Service $Spooler -Force
            $msg.AppendLine("Remote printing disabled.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        elseif ($state -and ($state.RegisterSpoolerRemoteRpcEndPoint -eq $RemotePrintEnable)) {
            Set-ItemProperty -Path (Join-Path -Path $PrintPath -ChildPath $RemotePrintPath) -Name $RemotePrintName -Value $RemotePrintDisable -Force
            Restart-Service $Spooler -Force
            $msg.AppendLine("Remote printing was enabled but was now set to disabled.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
    }
    if ($DisableRemotePrint -eq 0) {
        if (!$state) {
            $msg.AppendLine("Remote printing was not configured, nothing changed.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        elseif ($state -and ($state.RegisterSpoolerRemoteRpcEndPoint -eq $RemotePrintDisable)) {
            Remove-ItemProperty -Path (Join-Path -Path $PrintPath -ChildPath $RemotePrintPath) -Name $RemotePrintName
            Restart-Service $Spooler -Force
            $msg.AppendLine("Remote printing key was removed.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
    }
    if ($SetACL -eq 1) {
        if ($DenyACL.count -eq 0) {
            $Acl.AddAccessRule($Ar)
            Set-Acl $Path $Acl
            $msg.AppendLine("ACL was set.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        else {
            $msg.AppendLine("ACL was already set.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }

    }
    if ($SetACL -eq 0) {
        if ($DenyACL.count -eq 0) {
            $msg.AppendLine("ACL was already Removed.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
        else {
            $Acl.RemoveAccessRule($Ar)
            Set-Acl $Path $Acl
            $msg.AppendLine("ACL was Removed.`n")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
    }
}
catch {
    $msg.AppendLine("$_")
    $exitCode = 1
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
}    

#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode