<#
    .SYNOPSIS
    Checks and remove all leftover SU Beta things
    
    .DESCRIPTION
    Checks and remove all leftover SU Beta things
#>

$PSINIFilePAth = "C:\Windows\System32\GroupPolicy\Machine\Scripts"
$PSINIFileName = "psscripts.ini"

$PSINIRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0"

if (Test-Path ($PSINIFilePAth + "\" + $PSINIFileName)) {
    Write-Output "Remove PSINI File"
    Remove-Item -Path ($PSINIFilePAth + "\" + $PSINIFileName)
    Write-Output "Call GPUpdate"
    gpupdate.exe /force
}
if (Test-Path $PSINIRegPath) {
    Write-Output "Remove Reg Entrys"
    Remove-Item -Path $PSINIRegPath -Force -Recurse
    Write-Output "Restart CCService"
    Restart-Service -Name CCService
}