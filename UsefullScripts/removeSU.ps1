<#
    .SYNOPSIS
    Checks and remove all leftover SU Beta things
    
    .DESCRIPTION
    Checks and remove all leftover SU Beta things
#>

#Requires -Version 5.0
#Requires -RunAsAdministrator

$PSINIFilePAth = "C:\Windows\System32\GroupPolicy\Machine\Scripts"
$PSINIFileName = "psscripts.ini"
$TriggerPatchRun = "C:\Program Files (x86)\Server-Eye\triggerPatchRun.cmd"

$PSINIRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\"

if (Test-Path ($PSINIFilePAth + "\" + $PSINIFileName)) {
    Write-Output "Checking $PSINIFileName File for SU Script"
    $content = Get-Content (($PSINIFilePAth + "\" + $PSINIFileName))
    $string = $content | Select-String -Pattern "triggerPatchRun.cmd"
    $SetNumber = ($string.ToString()).Substring(0, 1)
    Write-Output "Remove Lines form File"
    $content | Select-String -Pattern $SetNumber -NotMatch | Set-Content -Path (($PSINIFilePAth + "\" + $PSINIFileName))
    Write-Output "Call GPUpdate"
    gpupdate.exe /force
}
