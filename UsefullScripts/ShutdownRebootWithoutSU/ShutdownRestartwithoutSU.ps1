Param ( 
    [switch]$Shutdown,
    [switch]$Reboot
)


Get-Service -DisplayName "Server-Eye*" | Stop-Service
if ($Reboot) {
    Restart-Computer -Force
}elseif ($shutdown) {
    Stop-Computer -Force
}else {
    Write-Output -InputObject "No Reboot or Shutdown was given please provide one"
}
