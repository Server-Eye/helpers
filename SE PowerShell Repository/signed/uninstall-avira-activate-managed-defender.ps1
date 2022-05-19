<# 
    .SYNOPSIS
        Uninstall Avira Antivirus and the Avira Launcher.

    .DESCRIPTION
        This Script will Uninstall Avira Antivirus and the Avira Launcher form the System and remove Avira Sensor and also add Managed Defender Sensor.

    .PARAMETER Restart
        Set to something other then 0 to Restart after Avira uninstall.

    .PARAMETER AddDefender
        Set to something other then 0 to add the Server-Eye Managed Windows Defender Sensor.

    .PARAMETER Apikey
        API Key mandatory to remove or add Sensors.

    .NOTES
        When the CoreVersion of PowerShell is used no Eventlogs will be written.
        Author  : Server-Eye
        Version : 1.0
    
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to Restart after Avira uninstall")]
    [int]$Restart = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to add the Server-Eye Managed Windows Defender Sensor")]
    [int]$AddDefender = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "API Key to remove or add Sensors")] 
    [String]$Apikey
)

Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
    #region Register Eventlog Source
    try { New-EventLog -Source "ServerEyeManagedAntivirus" -LogName "Application" -ErrorAction Stop | Out-Null }
    catch { }
    #endregion Register Eventlog Source
    Checkpoint-Computer -Description "Pre Server-Eye MAV Uninstall" -RestorePointType "APPLICATION_UNINSTALL"
    #region WriteLog
    $script:_SilentOverride = $true
    $script:_LogFilePath = "C:\ProgramData\ServerEye3\logs\ServerEye.Extension.MAV.Uninstall.log"
    #region WriteLog
    function Write-Log
    {
        <#
            .SYNOPSIS
                A swift logging function.
            
            .DESCRIPTION
                A simple way to produce logs in various formats.
                Log-Types:
                - Eventlog (Application --> ServerEyeDeployment)
                - LogFile (Includes timestamp, EntryType, EventID and Message)
                - Screen (Includes only the message)
            
            .PARAMETER Message
                The message to log.
            
            .PARAMETER Silent
                Whether anything should be written to host. Is controlled by the closest scoped $_SilentOverride variable, unless specified.
            
            .PARAMETER ForegroundColor
                In what color messages should be written to the host.
                Ignored if silent is set to true.
            
            .PARAMETER NoNewLine
                Prevents output to host to move on to the next line.
                Ignored if silent is set to true.
            
            .PARAMETER EventID
                ID of the event as logged to both the eventlog as well as the logfile.
                Defaults to 1000
            
            .PARAMETER EntryType
                The type of event that is written.
                By default an information event is written.
            
            .PARAMETER LogFilePath
                The path to the file (including filename) that is written to.
                Is controlled by the closest scoped $_LogFilePath variable, unless specified.
            
            .EXAMPLE
                PS C:\> Write-Log 'Test Message'
        
                Writes the string 'Test Message' with EventID 1000 as an information event into the application eventlog, into the logfile and to the screen.
            
            .NOTES
                Supported Interfaces:
                ------------------------
                
                Author:       Friedrich Weinmann
                Company:      die netzwerker Computernetze GmbH
                Created:      12.05.2016
                LastChanged:  12.05.2016
                Version:      1.0
        
                EventIDs:
                1000 : All is well
                4*   : Some kind of Error
                666  : Terminal Error
        
                10   : Started Download
                11   : Finished Download
                12   : Started Installation
                13   : Finished Installation
                14   : Started Configuring Sensorhub
                15   : Finished Configuriong Sensorhub
                16   : Started Configuring OCC Connector
                17   : Finished Configuring Sensorhub
                
        #>
        [CmdletBinding()]
        Param (
            [Parameter(Position = 0)]
            [string]
            $Message,
            
            [bool]
            $Silent = $_SilentOverride,
            
            [System.ConsoleColor]
            $ForegroundColor,
            
            [switch]
            $NoNewLine,
            
            [Parameter(Position = 1)]
            [int]
            $EventID = 1000,

            [Parameter(Position = 1)]
            [string]
            $Source,

            
            [Parameter(Position = 3)]
            [System.Diagnostics.EventLogEntryType]
            $EntryType = ([System.Diagnostics.EventLogEntryType]::Information),
            
            [string]
            $LogFilePath = $_LogFilePath
        )
        
        # Log to Eventlog
        try { Write-EventLog -Message $message -LogName 'Application' -Source $Source -Category 0 -EventId $EventID -EntryType $EntryType -ErrorAction Stop }
        catch { }
        
        # Log to File
        try { "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss");$EntryType;$EventID;$Message" | Out-File -FilePath $LogFilePath -Append -Encoding UTF8 -ErrorAction Stop }
        catch { }
        
        # Write to screen
        if (-not $Silent)
        {
            $splat = @{ }
            $splat['Object'] = $Message
            if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
            if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
            
            Write-Host @splat
        }
    }
    #endregion WriteLog
}
 
Process {
    try {
        if ($Apikey) {
            try {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Removing Avira Sensor"
                $CId = (Get-Content 'C:\Program Files (x86)\Server-Eye\config\se3_cc.conf' | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")
                $Sensors = Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$cid/agents" -Method Get -Headers @{"x-api-key" = $Apikey } 
                $MAVSensor = $Sensors | Where-Object { $_.subtype -eq "72AC0BFD-0B0C-450C-92EB-354334B4DAAB" }
                $DAVSensor = $Sensors | Where-Object { $_.subtype -eq "0000CBF2-63AA-4911-B26D-924C9FC7ABA6" }
                if ($MAVSensor) {
                    try {
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent/$($MAVSensor.ID)" -Method Delete -Headers @{"x-api-key" = $Apikey }
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Avira Sensor was removed"
                    }
                    catch {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }

                }else {
                    Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Avira Sensor not found"
                }
                if ($AddDefender -ne 0 -and !($DAVSensor)) {
                    Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed Defender Sensor"
                    $body = [PSCustomObject]@{
                        type     = "0000CBF2-63AA-4911-B26D-924C9FC7ABA6"
                        parentId = $CId
                        name     = "Managed Windows Defender"
                    }
                    $body = $body | ConvertTo-Json
                    try {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed Defender Sensor"
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent" -Method Post -Body $body -ContentType "application/json"  -Headers @{"x-api-key" = $Apikey } -ErrorAction Stop
                    }
                    catch {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }
                
                
                }            
            }
            catch {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2 
            }

        }
        if ((Test-Path "C:\Program Files\Avira\Antivirus\presetup.exe") -eq $true) {
            try {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Start-Process -FilePath "C:\Program Files\Avira\Antivirus\presetup.exe"  -ArgumentList "/remsilentnoreboot" -ErrorAction Stop
                $avira = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { ($_.Displayname -eq "Avira") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\Avira.OE.Setup.Bundle.exe" /uninstall /quiet') }
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Launcher"
                Start-Process -FilePath $avira.BundleCachePath -Wait -ArgumentList "/uninstall /quiet" -ErrorAction Stop
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Uninstallation of Avira successful."
                $ExitCode = 1
       
            }
            catch {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2
            }

            If ($Restart -ne 0) {
                Restart-Computer -Force
            }
        
        }
        else {
            Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3003 -EntryType Information -Message "No Avira installation found."
            $ExitCode = 3
        }
    }
    catch {
        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
        $ExitCode = 2
        
    }
}
 
End {
    exit $ExitCode
}
# SIG # Begin signature block
# MIITigYJKoZIhvcNAQcCoIITezCCE3cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhXGxVsSw6xcwlwCdJl6Q1HV6
# hcKgghDCMIIFQDCCBCigAwIBAgIQPoouYh6JSKCXNBstwZR1fDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAi
# BgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQTAeFw0yMTAzMTUwMDAw
# MDBaFw0yMzAzMTUyMzU5NTlaMIGnMQswCQYDVQQGEwJERTEOMAwGA1UEEQwFNjY1
# NzExETAPBgNVBAgMCFNhYXJsYW5kMRIwEAYDVQQHDAlFcHBlbGJvcm4xGTAXBgNV
# BAkMEEtvc3NtYW5zdHJhc3NlIDcxIjAgBgNVBAoMGUtyw6RtZXIgSVQgU29sdXRp
# b25zIEdtYkgxIjAgBgNVBAMMGUtyw6RtZXIgSVQgU29sdXRpb25zIEdtYkgwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD2ffa5PXcN75tpZewrLUVUmNWe
# GUKMJu49HDdY2hbChjEf3557YCC8Ch6z+JwH1Qw+X52mUFvVOxgiQXXSzVjT4kSf
# zBkW0id0tVhwSWGys8fral5roP5P2MGDYxusC1fsCwjjBWsWtsJBT3IHSI0RfZhO
# QU/NUIAdIqd9gB90wPQ2Bl/xJUosNN6kKTc95NZsL7br/qXK+rz+HP2b9FDJSnCo
# YXmlZQznNabuJmHKkgylu/QsGy5UeDLRH5HIESeb4TYVz2FK8dkNdTANY0LaKazP
# X5APMcevI8TL76CSVtzr3G5zVP6G7zCigjXsf+r0J+cq3X1nV+SBc9N0DTQhAgMB
# AAGjggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNV
# HQ4EFgQUv6NoXcU4+16wIL34u0CFr2BkBXswDgYDVR0PAQH/BAQDAgeAMAwGA1Ud
# EwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQ
# MEoGA1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBz
# Oi8vc2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJo
# dHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNy
# bDBzBggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGln
# by5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAKiH0uKG9
# MA1QtQkFdKpaP5pzussbm2FbgmwZiMeimTPKRNjmXm1XFYdbfNp6mHZrpRR7PO/B
# d+YgotlZbPHkzYa6bTSxqfiUwA+W4VdcfaGww9Nk7KoEsrJjKKmr9LD/LyCXbB7k
# f9dsM8vRw7fIp77x1owXiGvGKu263qEnqZwD5/fZbdKtkGAlhxnn+7o96UUjMg/h
# 3n9MxEUXArjkWSafpiQ3LUkcDEPDM1pTaYNaBjOKkKp7SFRA0XbnoBjuSBdZ9w7c
# f5UqIdlli/tTzvGjbJq70CuF8OktlRFmbwIqbvTHQrp8rNOcB0ZBtkAkoAmOEv2d
# o7MC2wPQExjMSTCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZI
# hvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hl
# c3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0
# ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIw
# MDAwMDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# TmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBV
# U0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZp
# Y2F0aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AIASZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx
# 1ns3KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRi
# ZNt/owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9
# UY41pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjn
# EjpNrkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+
# dE5px2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+
# DqVmsSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVm
# zyWIzYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7
# LQC/NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dU
# qD79dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW
# 6WK61l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYD
# VR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rP
# VIDh2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEG
# A1UdIAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNv
# bW9kb2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcB
# AQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkq
# hkiG9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW
# /qofnJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64
# tIrwkZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugU
# Grxx8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA
# 0xdcOds/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkq
# a4UxFMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2i
# SDBvmyYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UE
# ChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNB
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIz
# MTIzNTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hl
# c3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVk
# MSQwIgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYl
# ZilAhlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4u
# MyD6DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX
# 7Wpyvjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtK
# n52BxHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuos
# B69G2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFk
# MIIBYDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQU
# DuE6qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQI
# MAYBAf8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYI
# KwYBBQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6
# Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEph
# pNveaiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5A
# RokS9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOB
# N9O3ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10
# Xkp1fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVp
# bL6fICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8Aj
# ntIeQ3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbM
# Q5Lkuk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp
# 7As9V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm
# 8SoKC6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2Wnkz
# GJLjtXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoy
# Ji1qV3AcPKRYLqPzW0sH3DJZ84enGm1YMYICMjCCAi4CAQEwgZAwfDELMAkGA1UE
# BhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
# Zm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdv
# IFJTQSBDb2RlIFNpZ25pbmcgQ0ECED6KLmIeiUiglzQbLcGUdXwwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFEney3Ih79r781BCuDwJm8O2vEJJMA0GCSqGSIb3DQEBAQUABIIBAAG0
# 4o42RYVcQYrCDCYKNTyAtpWJaC+lsulxOyK4L0X/hGdF+YGseDa7GtWWTqRh7Ujp
# p7rwR/n4XJXbEklhSigUNMvii2zHqRzYKTurFBGOa680E+ESK2CuYI4+1T4Kq6zP
# DYf6gztwHQ76jzOnb1eGmiHeNpJvJdmeUqXZJJg+leXmmk1VvYv34sFZCebbO4Bd
# DjS/ewpLVRPVyhpXdIwoFzkujR9mKrLKdmAGcPSbdaxfF1GJxNopxvhO2AA1laBy
# qX+l8zVjzpgjqx57UKwmquEgiYEUi3yXUVTylO1FAa0pnv/iD8pvuH1hy+f9Dc4w
# 9qLkrZznzgqRFMUTf1o=
# SIG # End signature block
