#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Check Exchange
        
    .DESCRIPTION
        Check Exchange

    .NOTES
        Author  : Server-Eye,Krämer IT Solutions GmbH
        Version : 1.0

    .Link
    https://news.microsoft.com/de-de/hafnium-sicherheitsupdate-zum-schutz-vor-neuem-nationalstaatlichem-angreifer-verfuegbar/
    https://docs.microsoft.com/de-de/windows/security/threat-protection/intelligence/safety-scanner-download
#>

$DataPath = "C:\ProgramData\ServerEye3\Hafnium"
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $false
$script:_SilentEventlog = $true
$script:_LogFilePath = "{0}\CheckExchange.log" -f $DataPath
$INetPubPath = Join-Path -path (Get-WebFilePath 'IIS:\Sites\Default Web Site').root.name -ChildPath (Get-WebFilePath 'IIS:\Sites\Default Web Site').parent.name

#Region Helper Funtions
function Write-Log {
    <#
            .SYNOPSIS
                A swift logging function.
            
            .DESCRIPTION
                A simple way to produce logs in various formats.
                Log-Types:
                - Eventlog (Application --> ServerEye-Custom)
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
            
            .EXAMPLE
                PS C:\> Write-Log 'Test Message'
        
                Writes the string 'Test Message' with EventID 1000 as an information event into the application eventlog, into the logfile and to the screen.       
        #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [string]
        $Message,
            
        [bool]
        $Silent = $_SilentOverride,

        [bool]
        $SilentEventlog = $_SilentEventlog,
        
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
        $splat['Object'] = $Message
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
        if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
        Write-Host @splat
    }
}
function ZipnetLogs {
    param (
        $date
    )
    if (!(Test-Path "$DataPath\temp")) {
        New-Item -Path "$DataPath\temp" -Value "temp" -ItemType Directory
    }
    else {
        Remove-Item "$DataPath\temp" -Recurse
        New-Item -Path "$DataPath\temp" -Value "temp" -ItemType Directory
    }
    Get-ChildItem -Path "$INetPubPath\logs\logfiles" -Recurse -Directory | Copy-Item -Destination "$DataPath\temp"
    $files = Get-ChildItem -Path "$INetPubPath\logs\logfiles" -Recurse -File | Where-Object { $_.LastAccessTime -gt $date }
    foreach ($file in $files) {
        $path = "{0}\temp\{1}" -f $DataPath, $file.Directory.name
        Copy-Item -Path $file.fullname -Destination $path
    }
    if ((Test-Path "C:\Windows\debug\msert.log")) {
        Copy-Item -Path "C:\Windows\debug\msert.log" -Destination "$DataPath\temp"
    }
    if ((Get-Host).Version.major -ge 5) {
        Compress-Archive -Path "$DataPath\temp\*" -Update -DestinationPath "$DataPath\Logs.zip"
        Remove-Item "$DataPath\temp" -Recurse
        Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Files zipped"
    }
    else {
        Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "PowerShell is not 5.1 or greater Files not zipped"
    }

}
#endRegion Helper Funtions

$date = (Get-Date -Year 2021 -Month 03 -Day 01 -hour 00 -Minute 00 -second 00)
#Check if Exchange
$serverrole = get-service *msexch*

$credentials = Get-Credential
    #region Check Exchange and Path
if ($serverrole -ne $null) {


    Get-PSSnapin -Registered | where name -like *exch* | Add-PSSnapin
    $ExchangeServers = (get-exchangeserver)

    if (!(Test-path $DataPath)) {
        New-Item -Path $DataPath -ItemType directory -Value "Hafnium"
    }
    if ($ExchangeServers.count -eq 1) {
        
    }
    #endregion Check Exchange and Path
    
    #region ProxyLogon
    $TestProxyLogon = "https://github.com/microsoft/CSS-Exchange/releases/latest/download/Test-ProxyLogon.ps1"
    Start-BitsTransfer -Source $TestProxyLogon -destination "$Env:TEMP\Test-ProxyLogon.ps1"
    if (!(Test-Path "$DataPath\ProxyLogon")) {
        New-Item -Path "$DataPath\ProxyLogon" -Value "ProxyLogon" -ItemType Directory
    }
    $command = "Get-exchangeserver | $Env:TEMP\Test-ProxyLogon.ps1 -OutPath $DataPath\ProxyLogon"
    Invoke-Expression $command 

    if (Test-Path -Path "$datapath\*-Cve-2021-27065.log") {
        $content = Get-Content -Path "$datapath\*-Cve-2021-27065.log"
        Copy-Item -path $content -Destination "$DataPath"
    }
    #endregion ProxyLogon

    #region DCSkriptblocks
    $SBOnDCS = {
        param($exchange)
        $Source = "C:\ProgramData\ServerEye3\Security.evtx"
        $log = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Security'
        $log.BackupEventlog($Source) 
        $xmlfilter = "<QueryList><Query Id='0' Path='Security'><Select Path='Security'>*[System[(EventID=4624)]]and*[EventData[Data[@Name='TargetUserName'] and (Data='{0}$')]]and*[EventData[Data[@Name='AuthenticationPackageName'] and (Data='NTLM')]]or*[System[(EventID=5136)]]</Select></Query></QueryList>" -f $exchange
        Get-Winevent -FilterXml $xmlfilter -ErrorAction SilentlyContinue
    }

    $SBFindUpdate = {
        Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*KB5000871*" -or $_.DisplayName -like "*KB5000978*" } | Select-Object pscomputername, Displayname | Sort-Object pscomputername
    }
    #endregion DCSkriptblocks

    #region on DCs
    $allDCs = (Get-ADForest).Domains | Foreach-object { Get-ADDomainController -Filter * -Server $_ }
    $DCsEventCount = @()
    foreach ($ExchangeServer in $ExchangeServers) {
        foreach ($DC in $allDCs) {
            try {
                $result = Invoke-Command -ComputerNam $dc.name -Credential $credentials -ScriptBlock $SBOnDCS -ArgumentList $ExchangeServer.Name
                $Destination = "C:\ProgramData\ServerEye3\Hafnium\{0}SecurityWith{1}.evtx" -f $dc.name, $ExchangeServer.Name
                $Source = "\\{0}\C$\ProgramData\ServerEye3\Security.evtx" -f $dc.name
                Start-BitsTransfer -Source $Source -Destination $Destination
                $DCsEventCount += [PSCustomObject]@{
                    Server     = $DC.Name
                    Exchange   = $ExchangeServer.Name
                    EventCount = $result.Count
                }
            }
            catch {
                Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
            }

        }
    }
    Write-Output $DCsEventCount | Format-Table
    Out-File -Append -InputObject $DCsEventCount -FilePath $script:_LogFilePath -Encoding UTF8

    #endregion on DCs

    #region Exchange
    ZipnetLogs -date $date
    $ispatched = $ExchangeServer | Foreach-object { 
        if ($_.Name -eq $env:COMPUTERNAME) {
            Invoke-Command -ComputerName 127.0.0.1 -ScriptBlock $SBFindUpdate 
        }
        else {
            Invoke-Command -ComputerName $_.name -ScriptBlock $SBFindUpdate 
        }

    }
    if ($ispatched -eq $null) {
        Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "KB5000871 or KB5000978 not installed on one or more Exchange."
    }
    else {
        if ($ExchangeServers.admindisplayversion.major -like "*14*") {
            $INetRootPath = Join-Path -path $INetPubPath -ChildPath  "wwwroot\"
            $INetRoot = Get-ChildItem -path $INetRootPath -Filter *.aspx -recurse | Where-Object { $_.lastwritetime -gt $date }
            if ($INetRoot -ne $null) {
                Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Exchange Server 2010 is patched with KB5000978. Compromised ASPX Files found, run MSERT immediatelly!"

            }
            else {
                Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Exchange Server 2010 is patched with KB5000978, no compromised ASPX Files found"
            }
        }
        else {
            $HttpProxyPath = Join-Path -Path $env:exchangeinstallpath -ChildPath "FrontEnd\HttpProxy\"
            $INetRootPath = Join-Path -path $INetPubPath -ChildPath  "wwwroot\"
            $HttpProxy = Get-ChildItem -path $HttpProxyPath -Filter *.aspx -recurse | Where-Object { $_.lastwritetime -gt $date }
            $INetRoot = Get-ChildItem -path $INetRootPath -Filter *.aspx -recurse | Where-Object { $_.lastwritetime -gt $date }

            if ($HttpProxy -ne $null -or $INetRoot -ne $null) {
                Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Server is patched with KB5000871. Compromised ASPX Files found, run MSERT immediatelly!"
            }
            else {
                Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Server is patched with KB5000871, no compromised ASPX Files found"
            }  
        }
    }
    #endregion Exchange
}
else {
    Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "No Exchange Server"
}