$ErrorActionPreference = "Stop"
        Write-Host -ForegroundColor Green "Ohne Proxy einstellung wird gesetzt"
        bitsadmin.exe /util /setieproxy localsystem NO_PROXY


