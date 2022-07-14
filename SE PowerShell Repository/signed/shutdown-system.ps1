<#
    .SYNOPSIS
        Forces a system shutdown
 
    .DESCRIPTION
        Execution of this script forces an system shutdown after 10 seconds.
 
    .PARAMETER Comment 
        Comment for the shutdown, default is "Herunterfahren über die Aufgabenplanung".
 
    .PARAMETER reason 
        Reason for the system restart, can either be "P" or "U", default "P".
 
    .PARAMETER major 
        Specifies the major reason number (a positive integer, less than 256), default is 0.
 
    .PARAMETER minor 
        Specifies the minor reason number (a positive integer, less than 65536), default is 0.
 
    .PARAMETER Time 
        Time before the shutdown should occur, default is 10 seconds.
        
    .NOTES
        Author  : Server-Eye
        Version : 1.4
 
    .Link
        https://docs.microsoft.com/de-de/windows-server/administration/windows-commands/shutdown
 
        Reasons, major and minor settings:
        https://servereye.freshdesk.com/a/solutions/articles/14000128892
#>
 
[CmdletBinding()]
Param(
    [parameter(Mandatory = $false, HelpMessage = "Comment for the restart ")]
    [string]
    $Comment = "Herunterfahren über die Aufgabenplanung",
    [parameter(Mandatory = $false, HelpMessage = "Reason for the system restart, can either be 'P' or 'U', default 'P'.")]
    [ValidateSet("P", "U")]
    [string]
    $reason = "P",
    [parameter(Mandatory = $false, HelpMessage = "Specifies the major reason number (a positive integer, less than 256)")]
    [Int]
    $major = 0,
    [parameter(Mandatory = $false, HelpMessage = "Specifies the minor reason number (a positive integer, less than 65536)")]
    [Int]
    $minor = 0,
    [parameter(Mandatory = $false, HelpMessage = "Time before the restart should occur, default 10 seconds.")]
    [Int]
    $Time = 10
)
 
Begin {
    $SELogPath = Join-Path -Path $env:ProgramData -ChildPath "\ServerEye3\logs\"
    $SELog = Join-Path -Path $SELogPath -ChildPath "ServerEye.Task.RestartShutdown.log"
    $FileToRunpath = "C:\WINDOWS\system32\shutdown.exe"
    Write-Host "Script started"
    $ExitCode = 0   
    $argument = '/s /t {0} /c "{1}" /d {2}:{3}:{4}' -f $Time, $Comment, $reason, $major, $minor
    #region Arguments
    $startProcessParams = @{
        FilePath     = $FileToRunpath
        ArgumentList = $argument       
        NoNewWindow  = $true
        PassThru = $true
    }
    # 0 = everything is ok
}
 
Process {
    try {        
        $gpos = Get-ChildItem -Path "Registry::\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown"
 
        foreach($gpo in $gpos){
            $gpoLocation = "Registry::\" + $gpo.Name
            $subGpos = Get-ChildItem -Path $gpoLocation
        
            foreach($subGpo in $subGpos){
                    $gpoScript = ""
                    [string]$gpoScript = $subGpo.GetValue("Script")

                    if($gpoScript.Contains("triggerPatchRun.cmd")){
						Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO ServerEye.Task.Logic.PowerShell - Write force parameter to gpo registry"
						Set-Itemproperty -path $subGpo.PSPath -Name 'Parameters' -value 'force'
                    }
            }
        }
		
        Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Trigger system shutdown with Arguments: $($startProcessParams.ArgumentList)" 
		$ShutdownProcess = Start-Process @startProcessParams
 
    } catch {
        Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") ERROR  ServerEye.Task.Logic.PowerShell - Something went wrong: $_" # This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}
 
End {
    Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Script ended with $exitcode"
    exit $ExitCode
}
 
# SIG # Begin signature block
# MIIkfwYJKoZIhvcNAQcCoIIkcDCCJGwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBh+IWn/lGXYv7G
# VxczkGJN562z9I5tEqmrT7Uy/No8iqCCHm4wggVAMIIEKKADAgECAhA+ii5iHolI
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
# 9MdCunys05wHRkG2QCSgCY4S/Z2jswLbA9ATGMxJMIIFsTCCBJmgAwIBAgIQASQK
# +x44C4oW8UtxnfTTwDANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQw
# IgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwNjA5MDAw
# MDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhE
# aWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57
# G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9o
# k3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFh
# mzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463J
# T17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFw
# q1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yh
# Tzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU
# 75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LV
# jHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJ
# bOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8Qg
# UWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IB
# XjCCAVowDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6
# mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/
# BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBDAUAA4IBAQCaFgKlAe+B+w20WLJ4
# ragjGdlzN9pgnlHXy/gvQLmjH3xATjM+kDzniQF1hehiex1W4HG63l7GN7x5XGIA
# TfhJelFNBjLzxdIAKicg6okuFTngLD74dXwsgkFhNQ8j0O01ldKIlSlDy+CmWBB8
# U46fRckgNxTA7Rm6fnc50lSWx6YR3zQz9nVSQkscnY2W1ZVsRxIUJF8mQfoaRr3e
# sOWRRwOsGAjLy9tmiX8rnGW/vjdOvi3znUrDzMxHXsiVla3Ry7sqBiD5P3LqNutF
# cpJ6KXsUAzz7TdZIcXoQEYoIdM1sGwRc0oqVA3ZRUFPWLvdKRsOuECxxTLCHtic3
# RGBEMIIF9TCCA92gAwIBAgIQHaJIMG+bJhjQguCWfTPTajANBgkqhkiG9w0BAQwF
# ADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcT
# C0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAs
# BgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcN
# MTgxMTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjB8MQswCQYDVQQGEwJHQjEbMBkG
# A1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYD
# VQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUg
# U2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIYijTKF
# ehifSfCWL2MIHi3cfJ8Uz+MmtiVmKUCGVEZ0MWLFEO2yhyemmcuVMMBW9aR1xqkO
# UGKlUZEQauBLYq798PgYrKf/7i4zIPoMGYmobHutAMNhodxpZW0fbieW15dRhqb0
# J+V8aouVHltg1X7XFpKcAC9o95ftanK+ODtj3o+/bkxBXRIgCFnoOc2P0tbPBrRX
# BbZOoT5Xax+YvMRi1hsLjcdmG0qfnYHEckC14l/vC0X/o84Xpi1VsLewvFRqnbyN
# VlPG8Lp5UEks9wO5/i9lNfIi6iwHr0bZ+UYc3Ix8cSjz/qfGFN1VkW6KEQ3fBiSV
# fQ+noXw62oY1YdMCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMB0GA1UdDgQWBBQO4TqoUzox1Yq+wbutZxoDha00DjAOBgNVHQ8B
# Af8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUEFjAUBggrBgEFBQcD
# AwYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGG
# P2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0
# aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0
# dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNy
# dDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAgEATWNQ7Uc0SmGk295qKoyb8QAAHh1iezrXMsL2s+Bjs/thAIia
# G20QBwRPvrjqiXgi6w9G7PNGXkBGiRL0C3danCpBOvzW9Ovn9xWVM8Ohgyi33i/k
# lPeFM4MtSkBIv5rCT0qxjyT0s4E307dksKYjalloUkJf/wTr4XRleQj1qZPea3FA
# mZa6ePG5yOLDCBaxq2NayBWAbXReSnV+pbjDbLXP30p5h1zHQE1jNfYw08+1Cg4L
# BH+gS667o6XQhACTPlNdNKUANWlsvp8gJRANGftQkGG+OY96jk32nw4e/gdREmaD
# JhlIlc5KycF/8zoFm/lv34h/wCOe0h5DekUxwZxNqfBZslkZ6GqNKQQCd3xLS81w
# vjqyVVp4Pry7bwMQJXcVNIr5NsxDkuS6T/FikyglVyn7URnHoSVAaoRXxrKdsbwc
# Ctp8Z359LukoTBh+xHsxQXGaSynsCz1XUNLK3f2eBVHlRHjdAd6xdZgNVCT98E7j
# 4viDvXK6yz067vBeF5Jobchh+abxKgoLpbn0nu6YMgWFnuv5gynTxix9vTp3Los3
# QqBqgu07SqqUEKThDfgXxbZaeTMYkuO1dfih6Y4KJR7kHvGfWocj/5+kUZ77OYAR
# zdu1xKeogG/lU9Tg46LC0lsa+jImLWpXcBw8pFguo/NbSwfcMlnzh6cabVgwggau
# MIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAe
# Fw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9Ge
# TKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0
# hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZl
# jZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAsh
# aG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVY
# TXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1
# biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0QCir
# c0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+
# DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA
# +bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42Pg
# puE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzS
# M7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU
# uhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6
# mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsG
# AQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAE
# GTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1Z
# jsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8d
# B+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVp
# P0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp8
# 76i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2
# nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3
# ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQ
# txMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc
# 4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+Y
# AN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZ
# vAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQr
# H4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGxjCCBK6gAwIBAgIQCnpK
# iJ7JmUKQBmM4TYaXnTANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQg
# RzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDMyOTAwMDAw
# MFoXDTMzMDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5KpYjply8X9ZJ8BWCGPQz
# 7sxcbOPgJS7SMeQ8QK77q8TjeF1+XDbq9SWNQ6OB6zhj+TyIad480jBRDTEHukZu
# 6aNLSOiJQX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2sO37cKhypvTDGFtjavOuy
# 8YPRn80JxblBakVCI0Fa+GDTZSw+fl69lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8P
# UN7UWSxEdMAyRxlb4pguj9DKP//GZ888k5VOhOl2GJiZERTFKwygM9tNJIXogpTh
# LwPuf4UCyYbh1RgUtwRF8+A4vaK9enGY7BXn/S7s0psAiqwdjTuAaP7QWZgmzuDt
# rn8oLsKe4AtLyAjRMruD+iM82f/SjLv3QyPf58NaBWJ+cCzlK7I9Y+rIroEga0OJ
# yH5fsBrdGb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh/9sRL5IDMM4wt4sPXUSzQx0j
# UM2R1y+d+/zNscGnxA7E70A+GToC1DGpaaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f
# 6CvkFLIW1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/GbaR5Sa2Lf2GHBWj31HDj
# QpXonrubS7LitkE956+nGijJrWGwoEEYGU7tR5thle0+C2Fa6j56mJJRzT/JROeA
# iylCcvd5st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WM
# aiCPnshvMB0GA1UdDgQWBBSNZLeJIf5WWESEYafqbxw2j92vDTBaBgNVHR8EUzBR
# ME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# RzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsG
# AQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeCKZxDbwEtqzi1cBG/hBmL
# P13lhk++kzreKjlaOU7YhFmlvBuYquhs79FIaRk4W8+JOR1wcNlO3yMibNXf9lnL
# ocLqTHbKodyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/uSZW3s8zFp+4O4e8eOIqf
# 7xHJMUpYtt84fMv6XPfkU79uCnx+196Y1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0
# F6aHZE8+RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAGcqlEO2lHEdPu6cegPk8Q
# uTA25POqaQmoi35komWUEftuMvH1uzitzcCTEdUyeEpLNypM81zctoXAu3AwVXjW
# mP5UbX9xqUgaeN1Gdy4besAzivhKKIwSqHPPLfnTI/KeGeANlCig69saUaCVgo4o
# a6TOnXbeqXOqSGpZQ65f6vgPBkKd3wZolv4qoHRbY2beayy4eKpNcG3wLPEHFX41
# tOa1DKKZpdcVazUOhdbgLMzgDCS4fFILHpl878jIxYxYaa+rPeHPzH0VrhS/inHf
# ypex2EfqHIXgRU4SHBQpWMxv03/LvsEOSm8gnK7ZczJZCOctkqEaEf4ymKZdK5fg
# i9OczG21Da5HYzhHF1tvE9pqEG4fSbdEW7QICodaWQR2EaGndwITHDGCBWcwggVj
# AgEBMIGQMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEk
# MCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWduaW5nIENBAhA+ii5iHolIoJc0
# Gy3BlHV8MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIP/NBXN7AvgmO6wOQCwkljIeMuUQ
# GyVZr3AOVDJAKptAMA0GCSqGSIb3DQEBAQUABIIBAOJptB+bvsgRkg0Nuwog/izb
# o9jtJWJu6iVmNzvBY5RCCkkgMw1m+aktYUeUs7CufzJC1VQ3AgGAV6P/8gAncIF2
# GoZ01RGAecxMWMDxNp1paQmtLBlwC8sRO4STP9QFaewr2xWbNQDacewm0o9YdMBV
# kuD+4gTynI6dy9r6IndbzadXglhdtrYKzw3mEWSWcYb/lUBXPZyBgNxaT4h7G7Il
# xbmjGuS9p89l5XIaVR8M2Syn8ie7+fTgDee4rBpRB7INj4sZSqNH87rs6yaYK4ZJ
# 7obQVL+u74UGre/B10hptBIrTc9le+PdVEdu2F6BKmpBuePXFNIIH62wf4KpQtuh
# ggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAKekqInsmZQpAG
# YzhNhpedMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMjIwNzE0MDkzODExWjAvBgkqhkiG9w0BCQQxIgQg
# 9kLmVvjWRdvTRogZlQc97ukxFfRg62yw+Csjgxt9KewwDQYJKoZIhvcNAQEBBQAE
# ggIAe8Qbm9IopczXkCWMj4FxIweY6oKt583qPAB15ZymWstJTetJJFIQEqm07MBH
# FbqFwxHuf8k7Y1iFOKnCx+FkKJUb3PKAVAvvNxeaYqNRk3/gpcXVa4uQxJxmSvJh
# HdeiQ09XL2EzyAdJ4pK+GOubUu1w9bmBVKDF0RbM7PbN/6Egat7NEQBzgvEuc4xW
# 2oQjEcA/16vtIUcXVPn1VHr6BWLrKcugLGt7lDX+QNW1pKRRmgRgUBXTzYsuRD3x
# 5FlAEncOJi98qtHfErcVM2ezTbuVJMsaqj7QeEetDxpqSSJzjOfCANCjSfJNLwPf
# 9kLisIjREZfOqMqpERlb9wDSwWjDUJ59ebQ1ROcgp6AMyJzrpgVOAdVGnvTBWG/n
# HgFxC6Ekdwt0zJSENB4kGsRQELUxGlXkkdN/3vgEvz92Tuid36xCvVbe2bGUhvIO
# dNWHtSJ76yYBANfOyNi9wGQK/qFZxE4uvTFKwEZOlDKTgFKtv0S6Vlt0B749zAT/
# t2ve6D8U2UkO0E22AHrrD2eHB5y9Rn7JlHP59FakQiApkjbnPY5/PD7G5n43nFjw
# PJuFlcPhHQCTx3Lnyzw+PiU8esXZ3DjWuIZGUbyBiPyU5Sy0/2FSbocNWX4+U5LG
# CENKZ0eV9RzKCdOZXBvGQCKnZ67Yxq3NYH8XaN1RHuPrwmI=
# SIG # End signature block
