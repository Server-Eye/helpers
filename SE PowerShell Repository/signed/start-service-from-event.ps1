<#
    .SYNOPSIS
    Restart Service Event Action
 
    .DESCRIPTION
    Restart all Services based on the Event Actiondata

    .PARAMETER EventID
    ID of the Event, default is 1.

    .PARAMETER LogName
    Name of the Eventlog that should be checked, default is Server-Eye Client History

    .PARAMETER AgentID
    ID of a Sensor

    .PARAMETER AgentType
    ID of a Sensor Type

    .NOTES
    Author  : Server-Eye
    Version : 2.0
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false, HelpMessage = "ID of the Event, default is 1.")] 
    [int]$EventID = 1,
    [Parameter(Mandatory = $false, HelpMessage = "Name of the Eventlog that should be checked, default is Server-Eye Client History")] 
    [string]$LogName = "Server-Eye Client History",
    [Parameter(Mandatory = $false, HelpMessage = "ID of a Sensor")]
    [string]$AgentID,
    [Parameter(Mandatory = $false, HelpMessage = "ID of a Sensor Type")] 
    [alias("ServerEyeID")]
    [string]$AgentType
)
#region Internal
$SEPath = "C:\Program Files (x86)\Server-Eye"
$SEDataPath = Join-Path -Path $env:ProgramData -ChildPath "\ServerEye3\"
$SELogPath = Join-Path -Path $SEDataPath -ChildPath "logs\"
$script:_LogFilePath = Join-Path -Path $SELogPath -ChildPath "ServerEye.Tasks.Event.log"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $true

try { New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null }
catch { }

#region WriteLog
function Write-Log {
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

    try { Add-Content -Path $LogFilePath -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") $EntryType  ServerEye.PowerShell.Logic.$EventID  $Message" -Encoding utf8 }
    catch { }
        
    # Write to screen
    if (-not $Silent) {
        $splat = @{ }
        $splat['Object'] = $Message
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
        if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
            
        Write-Host @splat
    }
}
#endregion WriteLog

if (!$AgentID -and !$AgentType) {
    Write-Log -Source $EventSourceName -EventID 100 -EntryType Error -Message "Check Parameters, no AgentID or AgentType given."
    throw "Parameter AgentId or AgentType is missing"
    Exit 2
}
elseif ($AgentID) {
    $data = "||agentid||$AgentID" 
}
elseif ($AgentType) {
    $data = "||agenttype||$AgentType" 
}

$filter = @{
    LogName = $LogName
    Data    = $data
    ID      = $EventID
}

$Event = get-winevent -FilterHashtable $filter -MaxEvents 1
#Endregion Internal

$Eventdata = [PSCustomObject]@{
    Message    = ($Event.Properties[0].Value).Replace("||message||", "")
    agentid    = ($Event.Properties[1].Value).Replace("||agentid||", "")
    agenttype  = ($Event.Properties[2].Value).Replace("||agenttype||", "")
    eventid    = ($Event.Properties[3].Value).Replace("||eventid||", "")
    actiondata = ($Event.Properties[4].Value).Replace("||actiondata||servicesNotRunning=", "").Split(",")
}

try {
    foreach ($service in $Eventdata.actiondata) {
        if ($service -ne "") {
            try {
                Write-Log -Source $EventSourceName -EventID 100 -EntryType Information -Message "Restarting Service: $($service)"
                Start-Service -Name "$service"
            }
            catch {
                Write-Log -Source $EventSourceName -EventID 100 -EntryType Information -Message "Restart for Service: $($service) exited with Error: $_"
            }
        }
    }
}catch {
    Write-Log -Source $EventSourceName -EventID 101 -EntryType Error -Message "Restart for Service: $($Eventdata.actiondata) exited with Error: $_"
    Exit 1
}
# SIG # Begin signature block
# MIIeygYJKoZIhvcNAQcCoIIeuzCCHrcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAY1Qsn/lNMzfcB
# 5p7HOeFWtd59l5q3tdOpoYfZjGqW0qCCGLkwggVAMIIEKKADAgECAhA+ii5iHolI
# oJc0Gy3BlHV8MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDMxNTAwMDAwMFoXDTIzMDMxNTIzNTk1OVowgacxCzAJBgNV
# BAYTAkRFMQ4wDAYDVQQRDAU2NjU3MTERMA8GA1UECAwIU2FhcmxhbmQxEjAQBgNV
# BAcMCUVwcGVsYm9ybjEZMBcGA1UECQwQS29zc21hbnN0cmFzc2UgNzEiMCAGA1UE
# CgwZS3LDpG1lciBJVCBTb2x1dGlvbnMgR21iSDEiMCAGA1UEAwwZS3LDpG1lciBJ
# VCBTb2x1dGlvbnMgR21iSDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# APZ99rk9dw3vm2ll7CstRVSY1Z4ZQowm7j0cN1jaFsKGMR/fnntgILwKHrP4nAfV
# DD5fnaZQW9U7GCJBddLNWNPiRJ/MGRbSJ3S1WHBJYbKzx+tqXmug/k/YwYNjG6wL
# V+wLCOMFaxa2wkFPcgdIjRF9mE5BT81QgB0ip32AH3TA9DYGX/ElSiw03qQpNz3k
# 1mwvtuv+pcr6vP4c/Zv0UMlKcKhheaVlDOc1pu4mYcqSDKW79CwbLlR4MtEfkcgR
# J5vhNhXPYUrx2Q11MA1jQtoprM9fkA8xx68jxMvvoJJW3OvcbnNU/obvMKKCNex/
# 6vQn5yrdfWdX5IFz03QNNCECAwEAAaOCAZAwggGMMB8GA1UdIwQYMBaAFA7hOqhT
# OjHVir7Bu61nGgOFrTQOMB0GA1UdDgQWBBS/o2hdxTj7XrAgvfi7QIWvYGQFezAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
# AzARBglghkgBhvhCAQEEBAMCBBAwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwIw
# JTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQB
# MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGln
# b1JTQUNvZGVTaWduaW5nQ0EuY3JsMHMGCCsGAQUFBwEBBGcwZTA+BggrBgEFBQcw
# AoYyaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdD
# QS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqG
# SIb3DQEBCwUAA4IBAQAqIfS4ob0wDVC1CQV0qlo/mnO6yxubYVuCbBmIx6KZM8pE
# 2OZebVcVh1t82nqYdmulFHs878F35iCi2Vls8eTNhrptNLGp+JTAD5bhV1x9obDD
# 02TsqgSysmMoqav0sP8vIJdsHuR/12wzy9HDt8invvHWjBeIa8Yq7breoSepnAPn
# 99lt0q2QYCWHGef7uj3pRSMyD+Hef0zERRcCuORZJp+mJDctSRwMQ8MzWlNpg1oG
# M4qQqntIVEDRduegGO5IF1n3Dtx/lSoh2WWL+1PO8aNsmrvQK4Xw6S2VEWZvAipu
# 9MdCunys05wHRkG2QCSgCY4S/Z2jswLbA9ATGMxJMIIF9TCCA92gAwIBAgIQHaJI
# MG+bJhjQguCWfTPTajANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQK
# ExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0Eg
# Q2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAxMjMx
# MjM1OTU5WjB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# JDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+MmtiVm
# KUCGVEZ0MWLFEO2yhyemmcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/7i4z
# IPoMGYmobHutAMNhodxpZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o95ft
# anK+ODtj3o+/bkxBXRIgCFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdmG0qf
# nYHEckC14l/vC0X/o84Xpi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi6iwH
# r0bZ+UYc3Ix8cSjz/qfGFN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOCAWQw
# ggFgMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQO
# 4TqoUzox1Yq+wbutZxoDha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgw
# BgEB/wIBADAdBgNVHSUEFjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0gBAow
# CDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0
# LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2Bggr
# BgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNv
# bS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDov
# L29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0SmGk
# 295qKoyb8QAAHh1iezrXMsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNGXkBG
# iRL0C3danCpBOvzW9Ovn9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0s4E3
# 07dksKYjalloUkJf/wTr4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWAbXRe
# SnV+pbjDbLXP30p5h1zHQE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUANWls
# vp8gJRANGftQkGG+OY96jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/wCOe
# 0h5DekUxwZxNqfBZslkZ6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5NsxD
# kuS6T/FikyglVyn7URnHoSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGaSyns
# Cz1XUNLK3f2eBVHlRHjdAd6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh+abx
# KgoLpbn0nu6YMgWFnuv5gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZaeTMY
# kuO1dfih6Y4KJR7kHvGfWocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa+jIm
# LWpXcBw8pFguo/NbSwfcMlnzh6cabVgwggauMIIElqADAgECAhAHNje3JFR82Ees
# /ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAz
# MjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDG
# hjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6
# ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/
# qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3Hxq
# V3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVj
# bOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcp
# licu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZ
# girHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZG
# s506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHz
# NklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2
# ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJ
# ASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYD
# VR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8w
# HwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGG
# MBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgB
# hv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4Q
# TRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfN
# thKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1g
# tqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1Ypx
# dmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/um
# nXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+U
# zTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhz
# q6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11
# LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCY
# oCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvk
# dgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3
# OBqhK/bt1nz8MIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaXnTANBgkqhkiG
# 9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# OzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGlt
# ZVN0YW1waW5nIENBMB4XDTIyMDMyOTAwMDAwMFoXDTMzMDMxNDIzNTk1OVowTDEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSQwIgYDVQQDExtE
# aWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQC5KpYjply8X9ZJ8BWCGPQz7sxcbOPgJS7SMeQ8QK77q8TjeF1+
# XDbq9SWNQ6OB6zhj+TyIad480jBRDTEHukZu6aNLSOiJQX8Nstb5hPGYPgu/CoQS
# cWyhYiYB087DbP2sO37cKhypvTDGFtjavOuy8YPRn80JxblBakVCI0Fa+GDTZSw+
# fl69lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8PUN7UWSxEdMAyRxlb4pguj9DKP//G
# Z888k5VOhOl2GJiZERTFKwygM9tNJIXogpThLwPuf4UCyYbh1RgUtwRF8+A4vaK9
# enGY7BXn/S7s0psAiqwdjTuAaP7QWZgmzuDtrn8oLsKe4AtLyAjRMruD+iM82f/S
# jLv3QyPf58NaBWJ+cCzlK7I9Y+rIroEga0OJyH5fsBrdGb2fdEEKr7mOCdN0oS+w
# VHbBkE+U7IZh/9sRL5IDMM4wt4sPXUSzQx0jUM2R1y+d+/zNscGnxA7E70A+GToC
# 1DGpaaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f6CvkFLIW1oGhytowkGvub3XAsDYm
# sgg7/72+f2wTGN/GbaR5Sa2Lf2GHBWj31HDjQpXonrubS7LitkE956+nGijJrWGw
# oEEYGU7tR5thle0+C2Fa6j56mJJRzT/JROeAiylCcvd5st2E6ifu/n16awIDAQAB
# o4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSNZLeJ
# If5WWESEYafqbxw2j92vDTBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0
# YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGlt
# ZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQANLSN0ptH1+OpLmT8B
# 5PYM5K8WndmzjJeCKZxDbwEtqzi1cBG/hBmLP13lhk++kzreKjlaOU7YhFmlvBuY
# quhs79FIaRk4W8+JOR1wcNlO3yMibNXf9lnLocLqTHbKodyhK5a4m1WpGmt90fUC
# CU+C1qVziMSYgN/uSZW3s8zFp+4O4e8eOIqf7xHJMUpYtt84fMv6XPfkU79uCnx+
# 196Y1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0F6aHZE8+RokWYyBry/J70DXjSnBI
# qbbnHWC9BCIVJXAGcqlEO2lHEdPu6cegPk8QuTA25POqaQmoi35komWUEftuMvH1
# uzitzcCTEdUyeEpLNypM81zctoXAu3AwVXjWmP5UbX9xqUgaeN1Gdy4besAzivhK
# KIwSqHPPLfnTI/KeGeANlCig69saUaCVgo4oa6TOnXbeqXOqSGpZQ65f6vgPBkKd
# 3wZolv4qoHRbY2beayy4eKpNcG3wLPEHFX41tOa1DKKZpdcVazUOhdbgLMzgDCS4
# fFILHpl878jIxYxYaa+rPeHPzH0VrhS/inHfypex2EfqHIXgRU4SHBQpWMxv03/L
# vsEOSm8gnK7ZczJZCOctkqEaEf4ymKZdK5fgi9OczG21Da5HYzhHF1tvE9pqEG4f
# SbdEW7QICodaWQR2EaGndwITHDGCBWcwggVjAgEBMIGQMHwxCzAJBgNVBAYTAkdC
# MRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQx
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0Eg
# Q29kZSBTaWduaW5nIENBAhA+ii5iHolIoJc0Gy3BlHV8MA0GCWCGSAFlAwQCAQUA
# oIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcN
# AQkEMSIEIMYki2SeocTAxMtuPl0o+ux7PwOAdgvOOvVGSs0KkQ5yMA0GCSqGSIb3
# DQEBAQUABIIBAHzVXGfKeWEO+i7wbc8KaGhr8z7nizFQtJDgCWZ8yGlbWVEhEQu7
# r2AC1rNH9ht+J3av5stx/ZGik6q/QslSW7xWAy8OFQONNPyyON+VX4VIBpSq0JUe
# aq9rM6euTfLbFZXph4kDQHxFLcveN/g3HendkPalUuxidQXnBLpu1xv85O+vO0jS
# Ht1vn+/LC5iLLFYF/J6ikVxLPjXKJQLDT6312Ga+CtoUkzDvbtDjUs06JjYuAimU
# 2sAmS++u2Pz9iz0YTLLTwuOTufqZ5KcLjuwbjRvhnvnQo/pS3w0zTctBqwC2uN6o
# fK2LP+LIT2uDUC3AfyhHKekULzSgd8h0c4mhggMgMIIDHAYJKoZIhvcNAQkGMYID
# DTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBAhAKekqInsmZQpAGYzhNhpedMA0GCWCGSAFlAwQCAQUA
# oGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIw
# NTE5MTM1ODIyWjAvBgkqhkiG9w0BCQQxIgQgqKrolv7EvYT19/f0Pgm3eMZoC/1+
# EhhULTjQuz6CCoowDQYJKoZIhvcNAQEBBQAEggIAH4SDMn8r6cT2EwXpPPlkuh17
# UKkm58h1HiQe1iaNuD27zllULtzC/K7h6h/GirFU8brrPq/49688ovgRT7kdGpAH
# 5huebyVeQ8KRBVR8//r4BPmLjMvFOvhJGH2xf421gDghFR2Ztbh9fI+okhi+seMa
# PJrZQfIzIiWpDTHPg6gmTv4wO4HnxTVKuFGliAUJF8oi1ulMKKie6mRETqo9WXRd
# TZedioqRcHeXTxoqMont/qCo4g0ZoHA77fvn54/pTT+IREvquC4BQscq1V5nHTEt
# HBq5I5NzK1XSeDoEdcZDPeQRyR3odEO0u1SC6SM8gAumPbg0esWpa1+UANjLgKVz
# AK9suFWNx1o2X3qTk6814jtvqD40w1ANyzHJHkqR9kEwo7/c4Z0iQg+jPsjGUkYQ
# RToEuAkyMk6oHRGHLEs3D/2r1B1mlbD1nd/NmyHbs+NzVg+bYcaTUnFKM4ZY1mRS
# jRKkG36y/nBHWbywbEhAYr3ppAzIFYd0iPxK/hFCYfQNBXBoTVJkrVWOZAiN0+PB
# sm4uv8Yy83p9+/s6nV10inngKDGdz/V+jhyEOB+ysa05q4ZZFbFWqkaeDYCEnLil
# coWSAcyXRUTg5VLhmfaZEAXbQqDPZ4KmjdoAOvsJ82bfJ6Y/2768IpNP2Hdb1Wwh
# gfdv5ejWCzuzZR5bxDw=
# SIG # End signature block
