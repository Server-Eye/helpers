#Requires -Version 5.0
#Requires -RunAsAdministrator


<#
    .SYNOPSIS
        Checks for KB number
        
    .DESCRIPTION
        Gets installed products from all systems of all customers and checks for Kaspersky
 
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>
 


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [Alias("ApiKey", "Session")]
    [string]
    $authToken
)

	#region Internal Function
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
 
            .PARAMETER SilentEventlog
            Whether anything should be written to the Eventlog. Is controlled by the closest scoped $_SilentEventlog variable, unless specified.
            
            .PARAMETER ForegroundColor
                In what color messages should be written to the host.
                Ignored if silent is set to true.
            
            .PARAMETER NoNewLine
                Prevents Debug to host to move on to the next line.
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
 
        #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [string]
        $Message,
            
        [bool]
        $Silent = $false,
 
        [bool]
        $SilentEventlog = $true,
        
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
        $LogFilePath = "C:\ProgramData\ServerEye3\logs\ServerEye.Script.checkKBonAllSystems.log"
    )
        
    # Log to Eventlog
    if (-not $SilentEventlog) {
        try { Write-EventLog -Message $message -LogName 'Application' -Source $Source -Category 0 -EventId $EventID -EntryType $EntryType -ErrorAction Stop }
        catch { }
    }

        
    # Log to File
    try { "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $EntryType $EventID - $Message" | Out-File -FilePath $LogFilePath -Append -Encoding UTF8 -ErrorAction Stop }
    catch { }
        
    # Write to screen
    if (-not $Silent) {
        $splat = @{ }
        $splat['Message'] = $Message
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { 
            $ForegroundColor = $PSBoundParameters["ForegroundColor"]
        }else{
            $ForegroundColor = "White"
        }

        Write-Host @splat -ForegroundColor $ForegroundColor
    }
}
 
#endregion Internal Function


Write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "Installing neccessary components. This could take a few minutes..."

Install-Module -Name ServerEye.Powershell.Helper
Import-Module -Name ServerEye.Powershell.Helper
Install-Module ImportExcel -Scope CurrentUser

Write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "Installing successful." 

$list = @()

Try{
    $mynodes = (Get-SeApiMyNodesList -Filter customer -AuthToken $authToken -listType object) 
    $customerlist = $mynodes.managedcustomers

    foreach($customer in $customerlist){
        $containerList = Get-SeApiCustomerContainerList -CId $customer.id -AuthToken $authToken

        foreach($container in $containerList){
            if($container.subtype -eq 2){
                write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "Get Inventory from $($customer.name) - $($container.name)"

                try{
                    $job = Start-Job -ScriptBLock { 
                        Get-SeApiContainerInventory -CId $args[0] -AuthToken $args[1]            
                    } -ArgumentList $container.id, $authToken 

                    $job | Wait-Job -Timeout 5

                    $inventory = Receive-Job -Job $job -Keep

                        if($inventory -eq $null){
                            Write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "timeout. Container $($container.name) is offline or no inventory data available"

                            $element = "" | Select-Object customer, container, containerID, productname, info
                            $element.customer = $customer.name
                            $element.container = $container.name
                            $element.containerID = $container.id
                            $element.productname = ""
                            $element.info = "keine Inventardaten vorhanden"
                            $list += $element
                        }else{
                            Write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "Check Kaspersky products for $($container.name) "

                            $programs = $inventory.PROGRAMS <#| Where-Object { $_.PRODUCT -like "Microsoft%" }     #>    
                            
                            foreach($program in $programs){                      
                                if($program.PRODUKT -like "Kaspersky*"){
                                    Write-Log -Source "ServerEye-Custom" -EventID 3200 -EntryType Information -Message "Kaspersky Produkt wurde gefunden" -ForegroundColor Green

                                    $element = "" | Select-Object customer, container, containerID, productname, info
                                    $element.customer = $customer.name
                                    $element.container = $container.name
                                    $element.containerID = $container.id
                                    $element.productname = $program.PRODUKT
                                    $element.info = "Kasperky Installation gefunden"
                                    $list += $element
                                    
                                }
                            }
                        }
                                                    
                }catch{
                    $ErrorMessage = $_.Exception.Message
                    Write-Log -Source "ServerEye-Custom" -EventID 3251 -EntryType Error -Message "$ErrorMessage" -ForegroundColor Red
                }
            }
                
        }        
    }   
    

    $list | Export-Excel

}Catch{
    $ErrorMessage = $_.Exception.Message
    Write-Log -Source "ServerEye-Custom" -EventID 3251 -EntryType Error -Message "$ErrorMessage" -ForegroundColor Red
}
# SIG # Begin signature block
# MIIacAYJKoZIhvcNAQcCoIIaYTCCGl0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYt3zem1OujRtgzx30g37dN1M
# vHqgghV0MIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMxMDEw
# NjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2UtAxQ
# tSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4CGPN4
# bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xObTOK
# fF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wODMSlK
# XAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwfoYer
# vnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgwggG0
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEWG2h0
# dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4prtLk
# YaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYDVR0f
# BGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJl
# ZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0CiNH
# o6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1UUp4
# eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2QzI2h
# F3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnYIpp1
# FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oNcX6X
# t/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEwggQZ
# oAMCAQICEAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4X
# DTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
# MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6gpnF
# OVQoV7YjSsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjWahQA
# OPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oiPhis
# EeTwmQNtO4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTGTSQj
# MF287DxgaqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgPhH+f
# MRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2srOlW
# /5MCAwEAAaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1bjAf
# BgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAGAQH/
# AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
# bDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDig
# NoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9xafD
# DiBCLK938ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIlHsS6
# HHssIeLWWywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8pieV4
# H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4UijGHK
# eZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8QkIo
# xhhWz0E0tmZdtnR79VYzIi8iNrJLokqV2PWmjlIwggVAMIIEKKADAgECAhA+ii5i
# HolIoJc0Gy3BlHV8MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYD
# VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBT
# aWduaW5nIENBMB4XDTIxMDMxNTAwMDAwMFoXDTIzMDMxNTIzNTk1OVowgacxCzAJ
# BgNVBAYTAkRFMQ4wDAYDVQQRDAU2NjU3MTERMA8GA1UECAwIU2FhcmxhbmQxEjAQ
# BgNVBAcMCUVwcGVsYm9ybjEZMBcGA1UECQwQS29zc21hbnN0cmFzc2UgNzEiMCAG
# A1UECgwZS3LDpG1lciBJVCBTb2x1dGlvbnMgR21iSDEiMCAGA1UEAwwZS3LDpG1l
# ciBJVCBTb2x1dGlvbnMgR21iSDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAPZ99rk9dw3vm2ll7CstRVSY1Z4ZQowm7j0cN1jaFsKGMR/fnntgILwKHrP4
# nAfVDD5fnaZQW9U7GCJBddLNWNPiRJ/MGRbSJ3S1WHBJYbKzx+tqXmug/k/YwYNj
# G6wLV+wLCOMFaxa2wkFPcgdIjRF9mE5BT81QgB0ip32AH3TA9DYGX/ElSiw03qQp
# Nz3k1mwvtuv+pcr6vP4c/Zv0UMlKcKhheaVlDOc1pu4mYcqSDKW79CwbLlR4MtEf
# kcgRJ5vhNhXPYUrx2Q11MA1jQtoprM9fkA8xx68jxMvvoJJW3OvcbnNU/obvMKKC
# Nex/6vQn5yrdfWdX5IFz03QNNCECAwEAAaOCAZAwggGMMB8GA1UdIwQYMBaAFA7h
# OqhTOjHVir7Bu61nGgOFrTQOMB0GA1UdDgQWBBS/o2hdxTj7XrAgvfi7QIWvYGQF
# ezAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEF
# BQcDAzARBglghkgBhvhCAQEEBAMCBBAwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIB
# AwIwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EM
# AQQBMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2Vj
# dGlnb1JTQUNvZGVTaWduaW5nQ0EuY3JsMHMGCCsGAQUFBwEBBGcwZTA+BggrBgEF
# BQcwAoYyaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25p
# bmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0G
# CSqGSIb3DQEBCwUAA4IBAQAqIfS4ob0wDVC1CQV0qlo/mnO6yxubYVuCbBmIx6KZ
# M8pE2OZebVcVh1t82nqYdmulFHs878F35iCi2Vls8eTNhrptNLGp+JTAD5bhV1x9
# obDD02TsqgSysmMoqav0sP8vIJdsHuR/12wzy9HDt8invvHWjBeIa8Yq7breoSep
# nAPn99lt0q2QYCWHGef7uj3pRSMyD+Hef0zERRcCuORZJp+mJDctSRwMQ8MzWlNp
# g1oGM4qQqntIVEDRduegGO5IF1n3Dtx/lSoh2WWL+1PO8aNsmrvQK4Xw6S2VEWZv
# Aipu9MdCunys05wHRkG2QCSgCY4S/Z2jswLbA9ATGMxJMIIF9TCCA92gAwIBAgIQ
# HaJIMG+bJhjQguCWfTPTajANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYD
# VQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBS
# U0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAx
# MjMxMjM1OTU5WjB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+Mm
# tiVmKUCGVEZ0MWLFEO2yhyemmcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/
# 7i4zIPoMGYmobHutAMNhodxpZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o
# 95ftanK+ODtj3o+/bkxBXRIgCFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdm
# G0qfnYHEckC14l/vC0X/o84Xpi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi
# 6iwHr0bZ+UYc3Ix8cSjz/qfGFN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOC
# AWQwggFgMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQW
# BBQO4TqoUzox1Yq+wbutZxoDha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHSUEFjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0g
# BAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRy
# dXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2
# BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0
# LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0
# cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0
# SmGk295qKoyb8QAAHh1iezrXMsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNG
# XkBGiRL0C3danCpBOvzW9Ovn9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0
# s4E307dksKYjalloUkJf/wTr4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWA
# bXReSnV+pbjDbLXP30p5h1zHQE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUA
# NWlsvp8gJRANGftQkGG+OY96jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/
# wCOe0h5DekUxwZxNqfBZslkZ6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5
# NsxDkuS6T/FikyglVyn7URnHoSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGa
# SynsCz1XUNLK3f2eBVHlRHjdAd6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh
# +abxKgoLpbn0nu6YMgWFnuv5gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZa
# eTMYkuO1dfih6Y4KJR7kHvGfWocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa
# +jImLWpXcBw8pFguo/NbSwfcMlnzh6cabVgxggRmMIIEYgIBATCBkDB8MQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3Rp
# Z28gUlNBIENvZGUgU2lnbmluZyBDQQIQPoouYh6JSKCXNBstwZR1fDAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUQBwtflewj8v73F9v8nd3U3EuXtMwDQYJKoZIhvcNAQEBBQAEggEA
# dg1TyhaeoWVciUxFxisFC0qCYAJpgNK/RMfR+5O6vQDHIt5rG5n+CUonb2+hxWSB
# QdF/nLEaBj+OJwynETRfAUvRq30KRaY/07yxDzL33XeUaQATRjSD3X/TKavp9ZpK
# bn5lqw7Em69BiLPVK9O6raXHiKFETuWWrlcWlmsh9C8Dr8xT3/y8ESLVxGViiNyI
# v86bHIXng7Qn4TkLV9yXexoFYp0TOQZvmQTS9kvF/GwpiNUBA4Mwwl1GhI81VBHE
# zJYE2gfNrBGJG3QXT/0PzJTAQU2BkRR5Yls5NQAKtYlL7EwjKSY75OthWJVoNmK7
# jr/2V3EKS2svM3lVO+70zKGCAjAwggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCB
# hjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3Vy
# ZWQgSUQgVGltZXN0YW1waW5nIENBAhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFl
# AwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
# DxcNMjIwNDAxMTI1MTEzWjAvBgkqhkiG9w0BCQQxIgQgr2wxxeFUu5YnJlD8JU8f
# jWxjl5z5zTNN+SwmsDrod/8wDQYJKoZIhvcNAQEBBQAEggEAXKex/jqfJ3poZ18b
# IDO1XKZWBQiXpPsrgZ+iOxa+SkpMSLGjHKCBNzfxsmXxg77WF1LN1u+E7RXeICAw
# QCbB9TxxHhFayo9vRRN5IHIRyCvR4llMQxSFS3UMI/n4zsnAI4AeqUL+WrGXKRau
# pqG9iwbFVPveXtyvCchg4jOtDcmvgDLTPbEuPYvxDIzD0fzyd5tDw+vWyxJTcvvd
# rSNYXdAad/5qNTFQLWlqvXCjkF9KVnrvSiqCFO/Du1FH18F8JzNoOKgWcbRMHlV0
# Zdj0cNlYpMAomB1q24Sb8qVFQV8TjMJGfS4UwWoN7vm8Pgkzexcm/QzW6vPFACcE
# Kqzwxg==
# SIG # End signature block
