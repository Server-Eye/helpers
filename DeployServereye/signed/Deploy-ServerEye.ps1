<#
	.SYNOPSIS
		This is the (mostly) silent Server-Eye installer.
	
	.DESCRIPTION
		This script will help to install Server-Eye on systems without a full UI or when a full interactive setup is not needed.
		Right now this script can download the current version of the client, install the client, setup an OCC-Connector and setup a Sensorhub.
	
	.PARAMETER Install
		Installs Server-Eye using the .msi files in the current directory.
	
	.PARAMETER Download
		Downloads the .msi files for Server-Eye matching the version number of the script.
	
	.PARAMETER Offline
		Skips all online checks. Use this only if the computer does not have an Internet connection.
		This should really only be used if all else fails. 
	
	.PARAMETER Deploy
		Assigns the connector to a specific customer.
	
	.PARAMETER Customer
		The customer ID to which the computer is added.
	
	.PARAMETER Secret
		The secret to authenticate the connection.
	
	.PARAMETER NodeName
		Optionally, a nodename can be prespecified.
	
	.PARAMETER ParentGuid
		Optionally, this node can be assigned to a specific parent node.
	
	.PARAMETER HubPort
		The port on the sensorhub to connect to.
		Comes preconfigured with the server-eye defaults. Don't change it unless you know what you do.
	
	.PARAMETER ConnectorPort
		The port on the connector to connect to.
		Comes preconfigured with the server-eye defaults. Don't change it unless you know what you do.

	.PARAMETER Silent
		Suppresses all verbosity and all interactive menus.
		Required for unattended installs.

	.PARAMETER SilentOCCConfirmed
		Confirms that the OCC Connector should be installed in silent (unattended) mode.

	.PARAMETER DeployPath
		The folder runtime files (especially downloaded installer files) are stored in.
		By default, the folder the script was called from. Since this location is not always reliable and sometimes other rules (e.g. Software Restriction Policy) must be honored, this can be configured.
		If the path is not present, the script will try to create it. If this fails, the script will terminate.

	.PARAMETER ApplyTemplate
		Applies a template after the deploy stage.

	.PARAMETER TemplateId
		The GUID of the template you want to apply to the SensorHub.

	.PARAMETER ApiKey
		Operations such as 'ApplyTemplate' require an API key. 

	.PARAMETER LogFile
		Path including filename. Logs messages also to that file.

	.PARAMETER NoExit
		Using this, the script is no longer terminated with "exit", allowing it to be used as part of a greater script.
	
	.EXAMPLE
		PS C:\> .\Deploy-ServerEye.ps1 -Download
		
		This just downloads the current version of the client setup.
	
	.EXAMPLE
		PS C:\> .\Deploy-ServerEye.ps1 -Download -Install
		
		This will download the current version of ServerEye and install it on this computer.
	
	.EXAMPLE
		PS C:\> .\Deploy-ServerEye.ps1 -Download -Install -Deploy All -Customer XXXXXX -Secret YYYYYY
		
		This will download the current version of ServerEye and install it on this computer.
		This will also set up an OCC-Connector and a Sensorhub on this computer for the given customer.
		The parameters Customer and Secret are required for this.
	
	.EXAMPLE
		PS C:\> .\Deploy-ServerEye.ps1 -Download -Install -Deploy SenorhubOnly -Customer XXXXXX -Secret YYYYYY -ParentGuid ZZZZZZ
		
		This will download the current version of ServerEye and install it on this computer.
		This will also set up a Sensorhub on this computer for the given customer.
		The parameters Customer, Secret and ParentGuid are required for this.
	
	.NOTES
		Creating customers with this is not yet supported.
	
	.LINK
		https://github.com/Server-Eye/se-installer-cli
#>

#Requires -Version 2

[CmdletBinding(DefaultParameterSetName = 'None')]
param (
	[switch]
	$Install,
	
	[switch]
	$Download,
	
	[switch]
	$Offline,
	
	[ValidateSet("All", "SensorHubOnly")]
	[string]
	$Deploy,
	
	[string]
	$Customer,
	
	[string]
	$Secret,
	
	[string]
	$NodeName,
	
	[string]
	$ParentGuid,
	
	[string]
	$HubPort = "11010",
	
	[string]
	$ConnectorPort = "11002",
	
	[string]
	$TemplateId,
	
	[switch]
	$ApplyTemplate,
	
	[string]
	$ApiKey,
	
	[switch]
	$Silent,
	
	[switch]
	$SilentOCCConfirmed,
	
	[string]
	$DeployPath,
	
	[switch]
    $SkipInstalledCheck,
    
    [switch]
    $SkipLogInstalledCheck,
	
	[string]
	$LogFile,
	
	[switch]
	$NoExit
)

#region Preconfigure some static settings
# Note: Changes in the infrastructure may require reconfiguring these and break scripts deployed without these changes
$SE_occServer = "occ.server-eye.de"
$SE_apiServer = "api.server-eye.de"
$SE_configServer = "config.server-eye.de"
$SE_pushServer = "push.server-eye.de"
$SE_queueServer = "queue.server-eye.de"
$SE_baseDownloadUrl = "https://$SE_occServer/download"
$SE_cloudIdentifier = "se"
$SE_vendor = "Vendor.ServerEye"
$wcVersion = new-object system.net.webclient
$SE_version = $wcVersion.DownloadString("$SE_baseDownloadUrl/$SE_cloudIdentifier/currentVersion")

if ($DeployPath -eq "")
{
	$DeployPath = (Resolve-Path .\).Path
}

# Create OCC Configuration Object
$OCCConfig = New-Object System.Management.Automation.PSObject -Property @{
	ConfFileMAC = ""
	Customer = $Customer
	Secret = $Secret
	NodeName = $NodeName
	ConnectorPort = $ConnectorPort
	ConfigServer = $SE_configServer
	PushServer = $SE_pushServer
	QueueServer = $SE_queueServer
}

# Create Sensorhub Configuration Object
$HubConfig = New-Object System.Management.Automation.PSObject -Property @{
	ConfFileCC = ""
	Customer = $Customer
	Secret = $Secret
	NodeName = $NodeName
	HubPort = $HubPort
	ParentGuid = $ParentGuid
}

# Create Template Configuration Object
$TemplateConfig = New-Object System.Management.Automation.PSObject -Property @{
	ApplyTemplate = $ApplyTemplate.ToBool()
	TemplateID = $TemplateId
	ApiKey = $ApiKey
}

# Set the global verbosity level
$script:_SilentOverride = $Silent.ToBool()

# Set global exit preference
$script:_NoExit = $NoExit.ToBool()

# Set the logfile path
if ($LogFile -eq "")
{
	$script:_LogFilePath = $env:TEMP + "\ServerEyeInstall.log"
}
else
{
	$script:_LogFilePath = $LogFile
}

#endregion Preconfigure some static settings

#region Register Eventlog Source
try { New-EventLog -Source 'ServerEyeDeployment' -LogName 'Application' -ErrorAction Stop | Out-Null }
catch { }
#endregion Register Eventlog Source

#region Utility Functions
function Test-64Bit
{
	[CmdletBinding()]
	Param (
		
	)
	return ([IntPtr]::Size -eq 8)
}

function Get-ProgramFilesDirectory
{
	[CmdletBinding()]
	Param (
		
	)
	
	if ((Test-64Bit) -eq $true)
	{
		Get-Item ${Env:ProgramFiles(x86)} | Select-Object -ExpandProperty FullName
	}
	else
	{
		Get-Item $env:ProgramFiles | Select-Object -ExpandProperty FullName
	}
}

function Write-Header
{
	[CmdletBinding()]
	Param (
		
	)
	
	# Suppress all text-output in silent mode
	if ($script:_SilentOverride) { return }
	
	$AsciiArt_ServerEye = @"
  ___                          ___         
 / __| ___ _ ___ _____ _ _ ___| __|  _ ___ 
 \__ \/ -_) '_\ V / -_) '_|___| _| || / -_)
 |___/\___|_|  \_/\___|_|     |___\_, \___|
                                  |__/     
"@
	Write-Host $AsciiArt_ServerEye -ForegroundColor DarkYellow
	Write-Host "                            Version 3.5.$SE_version`n" -ForegroundColor DarkGray
	Write-Host "Welcome to the (mostly) silent Server-Eye installer`n"
}

function Write-SEDeployHelp
{
	[CmdletBinding()]
	Param (
		
	)
	
	# Suppress all text-output in silent mode
	if ($script:_SilentOverride) { return }
	
	$me = ".\Deploy-ServerEye.ps1"
	Write-Header
	
	Write-host "This script needs at least one of the following parameters.`n" -ForegroundColor red
	
	Write-Host "$me -Download"
	Write-Host "Downloads the current version of Server-Eye.`n"
	
	Write-Host "$me -Install"
	Write-Host "Installs Server-Eye on this computer using the .msi files in this folder.`n"
	
	Write-Host "$me -Deploy [All|SensorHubOnly] -Customer XXXX -Secret YYYY"
	Write-Host "Sets up Server-Eye on this computer using the given customer and secret key.`n"
	
	Write-Host "$me -Download -Install -Deploy [All|SensorHubOnly] -Customer XXXX -Secret YYYY"
	Write-Host "Does all of the above.`n"
	
}

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
		
		[Parameter(Position = 2)]
		[System.Diagnostics.EventLogEntryType]
		$EntryType = ([System.Diagnostics.EventLogEntryType]::Information),
		
		[string]
		$LogFilePath = $_LogFilePath
	)
	
	# Log to Eventlog
	try { Write-EventLog -Message $message -LogName 'Application' -Source 'ServerEyeDeployment' -Category 0 -EventId $EventID -EntryType $EntryType -ErrorAction Stop }
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

function Stop-Execution
{
	[CmdletBinding()]
	Param (
		[Parameter(Position = 1)]
		[int]
		$Number = 1
	)
	
	if ($script:_NoExit) { break main }
	else { exit $Number }
}
#endregion Utility Functions

#region Main Functions
function Start-ServerEyeInstallation
{
	[CmdletBinding()]
	Param (
		[bool]
		$Silent = $_SilentOverride,
		
		[string]
		$Deploy,
		
		[bool]
		$Download,
		
		[bool]
		$Install,
		
		[string]
		$OCCServer,
		
		[string]
		$BaseDownloadUrl,
		
		[string]
		$Version,
		
		[string]
		$Path,
		
		$OCCConfig,
		
		$HubConfig,
		
		$TemplateConfig
	)
	
	if (-not $Silent) { Write-Header }
	
	#region Really install OCC Connector?
	if ((-not $Silent) -and ($Deploy -eq "All"))
	{
		Write-Log -Message "Ensuring user is sure setting up an OCC Connector is the proper parameterization" -Silent $true
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes, this will be the only OCC-Connector.", "This will continue to set up the OCC-Connector."
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No, another OCC-Connector is already running.  ", "This will cancel everything and end this installer."
		$unkown = New-Object System.Management.Automation.Host.ChoiceDescription "I &don't know. ", "Pick this if you are unsure."
		$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $unkown)
		$caption = ""
		$message = "Only one OCC-Connector should be installed in a network.`nIs this the only OCC-Connector?"
		$result = $Host.UI.PromptForChoice($caption, $message, $choices, 2)
		
		switch ($result)
		{
			0
			{
				Write-Host "Great, let's continue."
				Write-Log "User-Choice: Is sure. Continueing OCC Connector installation" -Silent $true
			}
			1
			{
				Write-Host "Then we better stop here. Use the switch '-Deploy SensorhubOnly' instead."
				Write-Log "User-Choice: Is sure that wrong choice. Interrupting OCC Connector installation" -Silent $true -EventID 1001
				Stop-Execution
			}
			2
			{
				Write-Host "Then we better stop here. Please make sure this is the only OCC-Connector."
				Write-Log "User-Choice: Is unsure that no other OCC Connector is present. Interrupting OCC Connector installation" -Silent $true -EventID 1002
				Stop-Execution
			}
		}
	}
	#endregion Really install OCC Connector?
	
	Write-Log "Starting installation process"
	
	if ($Download)
	{
		Write-Log "Starting Download Routine" -EventID 10
		Download-SEInstallationFiles -BaseDownloadUrl $BaseDownloadUrl -Path $Path -Version $Version
		Write-Log "Download Routine finished" -EventID 11
	}
	
	if ($Install)
	{
		Write-Log "Starting Installation Routine" -EventID 12
		Install-SEConnector -Path $Path
		Write-Log "Installation Routine finished" -EventID 13
	}
	
	if ($Deploy -eq "All")
	{
		Write-Log "Starting OCC Connector Configuration" -EventID 16
		$HubConfig.ParentGuid = New-SEOccConnectorConfig -OCCConfig $OCCConfig
		Write-Log "OCC Connector Configuration finished" -EventID 17
		Start-Sleep 5
		Write-Log "Starting Server-Eye Sensorhub Configuration" -EventID 14
		New-SESensorHubConfig -HubConfig $HubConfig
		Write-Log "Server-Eye Sensorhub Configuration finished" -EventID 15
	}
	
	if ($Deploy -eq "SensorhubOnly")
	{
		Write-Log "Starting Server-Eye Sensorhub Configuration" -EventID 14
		New-SESensorHubConfig -HubConfig $HubConfig
		Write-Log "Server-Eye Sensorhub Configuration finished" -EventID 15
	}
	
	if ($TemplateConfig.ApplyTemplate)
	{
		Write-Log "Starting to apply template to the SensorHub" -EventID 16
		$guid = Get-SensorHubId -ConfigFileCC $HubConfig.ConfFileCC
		Apply-Template -Guid $guid -ApiKey $TemplateConfig.ApiKey -templateId $TemplateConfig.TemplateId
		Write-Log "Finished to apply template to the SensorHub" -EventID 17
	}
	
	Write-Host "Finished!" -ForegroundColor Green
	
	Write-Host "`nPlease visit https://$OCCServer to add Sensors`nHave fun!"
	Write-Log "Installation successfully finished!" -EventID 1 -Silent $true
	Stop-Execution -Number 0
}

function Apply-Template
{
	[CmdletBinding()]
	Param (
		[string]
		$Guid,
		
		[string]
		$ApiKey,
		
		[string]
		$TemplateId
	)
	$url = "https://api.server-eye.de/2/container/$guid/template/$templateId"
	#$url = "https://api.server-eye.de/2/me"
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("x-api-key", $apiKey)
	
	try
	{
		$WebRequest = [System.Net.WebRequest]::Create($url)
		$WebRequest.Method = "POST"
		$WebRequest.Headers.Add("x-api-key", $apiKey)
		$WebRequest.ContentType = "application/json"
		$Response = $WebRequest.GetResponse()
		$ResponseStream = $Response.GetResponseStream()
		$ReadStream = New-Object System.IO.StreamReader $ResponseStream
		$Data = $ReadStream.ReadToEnd()
		
	}
	catch
	{
		#$result = $_.Exception.Response.GetResponseStream()
		
		Write-Log "Could not apply template. Error message: $($_.Exception) " -EventID 105 -ForegroundColor Red
		Stop-Execution -Number 1
	}
	
	Write-Log "Template applied" -EventID 106
}

function Get-SensorHubId
{
	[CmdletBinding()]
	Param (
		$ConfigFileCC
	)
	
	$pattern = '\bguid=\b'
	
	$i = 180
	Write-Log "Waiting for SensorHub GUID (max wait $i seconds)" -EventID 102 -Silent $Silent
	
	while ((-not ($guidFound = Select-String -Quiet -Path $ConfigFileCC -Pattern $pattern)) -and ($i -gt 0))
	{
		Start-Sleep -Seconds 1
		$i--
	}
	
	if ($guidFound)
	{
		$guid = Get-Content $ConfigFileCC | Select-String -Pattern $pattern
		$guid = $guid -replace "guid=", ''
		Write-Log "Found SensorHub with GUID $guid" -EventID 103 -Silent $Silent
		
	}
	else
	{
		Write-Log "Could not get GUID" -ForegroundColor Red -EventID 104 -Silent $Silent
		Stop-Execution -Number 1
	}
	
	
	$guid
}

function Download-SEInstallationFiles
{
	[CmdletBinding()]
	Param (
		[string]
		$BaseDownloadUrl,
		
		[string]
		$Version,
		
		[string]
		$Path
	)
	
	Write-Log "  getting current Server-Eye version... " -NoNewLine
	$wc = new-object system.net.webclient
	$curVersion = $wc.DownloadString("$BaseDownloadUrl/$SE_cloudIdentifier/currentVersion")
	Write-Log "done" -ForegroundColor Green

	Write-Log "  downloading ServerEye.Core... " -NoNewline
	Download-SEFile "$BaseDownloadUrl/$SE_cloudIdentifier/ServerEyeSetup.exe" "$Path\ServerEyeSetup.exe"
	Write-Log "done" -ForegroundColor Green
	
	Write-Log "  downloading ServerEye.Vendor... " -NoNewline
	Download-SEFile "$BaseDownloadUrl/vendor/$SE_vendor/Vendor.msi" "$Path\Vendor.msi"
	Write-Log "done" -ForegroundColor Green
	
	Write-Log "  downloading ServerEye.Core... " -NoNewline
	Download-SEFile "$BaseDownloadUrl/setup/ServerEye.msi" "$Path\ServerEye.msi"
	Write-Log "done" -ForegroundColor Green

	
}

function Install-SEConnector
{
	[CmdletBinding()]
	Param (
		[string]
		$Path
	)
	
	Write-Host "  installing Server-eye in Version:$SE_version...  " -NoNewline
	if (-not (Test-Path "$Path\Vendor.msi"))
	{
		Write-Host "failed" -ForegroundColor Red
		Write-Host "  The file Vendor.msi is missing." -ForegroundColor Red
		Write-Log -Message "Installation failed, file not found: $Path\Vendor.msi" -EventID 666 -EntryType Error -Silent $true
		Stop-Execution
	}

	if (-not (Test-Path "$Path\ServerEye.msi"))
	{
		Write-Host "failed" -ForegroundColor Red
		Write-Host "  The file ServerEye.msi is missing." -ForegroundColor Red
		Write-Log -Message "Installation failed, file not found: $Path\ServerEye.msi" -EventID 666 -EntryType Error -Silent $true
		Stop-Execution
	}
	if (-not (Test-Path "$Path\ServerEyeSetup.exe"))
	{
		Write-Host "failed" -ForegroundColor Red
		Write-Host "  The file ServerEyeSetup.exe is missing." -ForegroundColor Red
		Write-Log -Message "Installation failed, file not found: $Path\ServerEyeSetup.exe" -EventID 666 -EntryType Error -Silent $true
		Stop-Execution
	}
	
	Start-Process -Wait -FilePath "$Path\ServerEyeSetup.exe" -ArgumentList "/install /passive /quiet /l C:\kits\se\log.txt"
	Write-Host "done" -ForegroundColor Green
}

function New-SEOccConnectorConfig
{
	[CmdletBinding()]
	Param (
		$OCCConfig
	)
	try
	{
		Write-Log "  creating OCC-Connector configuration... " -NoNewline
		
		Set-Content -Path $OCCConfig.ConfFileMAC -ErrorAction Stop -Value @"
customer=$($OCCConfig.Customer)
secretKey=$($OCCConfig.Secret)
name=$($OCCConfig.NodeName)
description=
port=$($OCCConfig.ConnectorPort)
	
servletUrl=https://$($OCCConfig.ConfigServer)/
statUrl=https://$($OCCConfig.PushServer)/0.1/
pushUrl=https://$($OCCConfig.PushServer)/
queueUrl=https://$($OCCConfig.QueueServer)/
proxyType=EdS2vHJFGTNVHy4Uq570OQ==|===
proxyUrl=L8aGFOF4VKZiWLRQEb72lA==|===
proxyPort=lo/VY9yIpiJ46BYKnAtljQ==|===
proxyDomain=lo/VY9yIpiJ46BYKnAtljQ==|===
proxyUser=lo/VY9yIpiJ46BYKnAtljQ==|===
proxyPass=lo/VY9yIpiJ46BYKnAtljQ==|===
"@
		Write-Log "done" -ForegroundColor Green
		
		Write-Log "  starting OCC-Connector... " -NoNewline
		
		Set-Service MACService -StartupType Automatic
		Start-Service MACService
		
		Write-Log "done" -ForegroundColor Green
		
		Write-Log "  waiting for OCC-Connector to register with Server-Eye... " -NoNewline
		
		$guid = ""
		$maxWait = 300
		$wait = 0
		while (($guid -eq "") -and ($wait -lt $maxWait))
		{
			$x = Get-Content $OCCConfig.ConfFileMAC | Select-String "guid"
			if ($x.Line.Length -gt 1)
			{
				$splitX = $x.Line.ToString().Split("=")
				$guid = $splitX[1]
			}
			Start-Sleep 1
			$wait++
		}
		
		if ($guid -eq "")
		{
			Write-Log "failed" -ForegroundColor Red
			Write-Log "GUID was not generated in time." -ForegroundColor Red
			Write-Log "Stopping Execution: OCC Connector Configuration failed" -EventID 666 -EntryType Error
			Stop-Execution
		}
		
		Write-Log "done" -ForegroundColor Green
		return $guid
	}
	catch
	{
		Write-Log "Stopping Execution: An error occured during OCC Connector Configuration: $($_.Exception.Message)" -EventID 666 -EntryType Error
		Stop-Execution
	}
}

function New-SESensorHubConfig
{
	[CmdletBinding()]
	Param (
		$HubConfig
	)
	
	try
	{
		Write-Log "  creating Sensorhub configuration... " -NoNewline
		
		Set-Content -Path $HubConfig.ConfFileCC -ErrorAction Stop -Value @"
customer=$($HubConfig.Customer)
secretKey=$($HubConfig.Secret)
name=$($HubConfig.NodeName)
description=
port=$($HubConfig.HubPort)
"@

		if ($HubConfig.ParentGuid)
		{
			"parentGuid=$($HubConfig.ParentGuid)" | Add-Content $HubConfig.ConfFileCC  -ErrorAction Stop
		}
		
		Write-Log "done" -ForegroundColor Green
		
		Write-Log "  starting Sensorhub... " -NoNewline
		
		Set-Service CCService -StartupType Automatic
		Start-Service CCService
		
		Start-Service SE3Recovery
		
		Write-Log "done" -ForegroundColor Green
	}
	catch
	{
		Write-Log "Stopping Execution: An error occured during Sensorhub Configuration: $($_.Exception.Message)" -EventID 666 -EntryType Error
		Stop-Execution
	}
}

function Download-SEFile
{
	[CmdletBinding()]
	Param (
		[string]
		$Url,
		
		[string]
		$TargetFile
	)
	
	try
	{
		$uri = New-Object "System.Uri" "$url"
		$request = [System.Net.HttpWebRequest]::Create($uri)
		$request.set_Timeout(15000) #15 second timeout
		$response = $request.GetResponse()
		$totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
		$responseStream = $response.GetResponseStream()
		$targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
		$buffer = new-object byte[] 10KB
		$count = $responseStream.Read($buffer, 0, $buffer.length)
		$downloadedBytes = $count
		
		while ($count -gt 0)
		{
			$targetStream.Write($buffer, 0, $count)
			$count = $responseStream.Read($buffer, 0, $buffer.length)
			$downloadedBytes = $downloadedBytes + $count
			Write-Progress -activity "Downloading file '$($url.split('/') | Select-Object -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength) * 100)
		}
		
		Write-Progress -activity "Finished downloading file '$($url.split('/') | Select-Object -Last 1)'" -Status "Done" -Completed
		
		$targetStream.Flush()
		$targetStream.Close()
		$targetStream.Dispose()
		$responseStream.Dispose()
		
	}
	catch
	{
		
		Write-Log -Message "Error downloading: $Url - Interrupting execution - $($_.Exception.Message)" -EventID 666 -EntryType Error
		Stop-Execution
	}
}
#endregion Main Functions

:main do
{
	#region Validation
	#region Elevation Check
	If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		Write-Log -Message "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -EntryType Error -EventID 666 -ForegroundColor Red
		Stop-Execution
	}
	#endregion Elevation Check
	
	#region Invalid parameterization Check
	if ($Offline -and $Download)
	{
		Write-Log -Message "Invalid Parameter combination: Cannot use offline mode and download at the same time." -EventID 666 -EntryType Error
		Stop-Execution
	}
	
	if ((-not $Install) -and (-not $Download) -and (-not $ApplyTemplate) -and (-not $PSBoundParameters.ContainsKey('Deploy')))
	{
		# Give guidance
		if (-not $_SilentOverride) { Write-SEDeployHelp }
		Write-Log -Message "Invalid Parameter combination: Must specify at least one of the following parameters: '-Download', '-Install' or '-Deploy'." -EventID 666 -EntryType Error
		Stop-Execution
	}
	
	if (($Silent) -and (-not $SilentOCCConfirmed) -and ($Deploy -eq "All"))
	{
		Write-Log -Message "Invalid Parameters: Cannot silently install OCC Connector without confirming this with the Parameter '-SilentOCCConfirmed'" -EventID 666 -EntryType Error
		Stop-Execution
	}
	#endregion Invalid parameterization Check
	
	#region OSVersion Check
	If ([environment]::OSVersion.Version.Major -lt 6)
	{
		if (-not $script:_SilentOverride)
		{
			Write-Log -Message "Your operating system is not officially supported.`nThe install will most likely work but we can no longer provide support for Server-Eye on this system." -EntryType Warning -EventID 400
			
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes, continue without support", "The install will continue, but we cannot help you if something doesn't work."
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No, cancel the install", "End the install right now."
			$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$caption = ""
			$message = "Do you still want to install Server-Eye on this computer?"
			$result = $Host.UI.PromptForChoice($caption, $message, $choices, 1)
			if ($result -eq 1)
			{
				Write-Log -Message "Execution interrupted by user" -EventID 666 -EntryType Warning -Silent $true
				Stop-Execution
			}
			else { Write-Log -Message "Execution continued by user" -EventID 499 -EntryType Warning -Silent $true }
		}
		else
		{
			Write-Log -Message "Non-Supported OS detected, interrupting Installation" -EventID 666 -EntryType Error
			Stop-Execution
		}
	}
	#endregion OSVersion Check
	
	#region validate already installed
	$progdir = Get-ProgramFilesDirectory
	$confDir = "$progdir\Server-Eye\config"
	$confFileMAC = "$confDir\se3_mac.conf"
	$OCCConfig.ConfFileMAC = $confFileMAC
	$confFileCC = "$confDir\se3_cc.conf"
	$HubConfig.ConfFileCC = $confFileCC
	$seDataDir = "$env:ProgramData\ServerEye3"
	
	
	if ((-not $SkipInstalledCheck) -and (($Install -or $PSBoundParameters.ContainsKey('Deploy')) -and ((Test-Path $confFileMAC) -or (Test-Path $confFileCC) -or (Test-Path $seDataDir))))
	{   
        if(-not $SkipLogInstalledCheck){
            Write-Log -Message "Server-Eye is or was installed on this system. This script works only on system without a previous Server-Eye installation" -EventID 666 -EntryType Error -ForegroundColor Red    
        }
		
		Stop-Execution
	}
	#endregion validate already installed
	
	#region validate script version
	if (-not $Offline)
	{
		try
		{
			Write-Log -Message "Checking for new script version"
			$wc = new-object system.net.webclient
			$result = $wc.DownloadString("$SE_baseDownloadUrl/$SE_cloudIdentifier/currentVersionCli")
			if ($SE_version -lt $result)
			{
				Write-Log -Message @"
This version of the Server-Eye deployment script is no longer supported.
Please update to the newest version with this command:
Invoke-WebRequest "$($SE_baseDownloadUrl)/$($SE_cloudIdentifier)/Deploy-ServerEye.ps1" -OutFile Deploy-ServerEye.ps1
"@ -EventID 666 -EntryType Error
				Stop-Execution
			}
		}
		# Failing the update-check is not necessarily a game-over. Failure to download the actual packages will terminate script
		catch
		{
			Write-Log -Message "Failed to access version information: $($_.Exception.Message)" -EventID 404 -EntryType Warning
		}
	}
	#endregion validate script version
	
	#region Validate DeployPath
	if (-not (Test-Path $DeployPath))
	{
		try
		{
			$folder = New-Item -Path $DeployPath -ItemType 'Directory' -Force -Confirm:$false
			if ((-not $folder.Exists) -or (-not $folder.PSIsContainer))
			{
				Write-Log "Stopping Execution: Deployment Path: $DeployPath could not be created."
				Stop-Execution
			}
			else { $DeployPath = $folder.FullName }
		}
		catch
		{
			Write-Log "Stopping Execution: Deployment Path: $DeployPath could not be created: $($_.Exception.Message)"
			Stop-Execution
		}
	}
	else
	{
		$DeployPath = Get-Item -Path $DeployPath | Select-Object -ExpandProperty FullName -First 1
	}
	#endregion Validate DeployPath
	#endregion Validation
	
	# Finally launch into the main execution
	$params = @{
		Deploy = $Deploy
		Download = $Download
		Install = $Install
		OCCServer = $SE_occServer
		BaseDownloadUrl = $SE_baseDownloadUrl
		Version = $SE_version
		Path = $DeployPath
		OCCConfig = $OCCConfig
		HubConfig = $HubConfig
		TemplateConfig = $TemplateConfig
	}
	Start-ServerEyeInstallation @params
}
while ($false)

# SIG # Begin signature block
# MIIa0AYJKoZIhvcNAQcCoIIawTCCGr0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/OMHumddh7/LCOdKr4k/QUTT
# gASgghW/MIIEmTCCA4GgAwIBAgIPFojwOSVeY45pFDkH5jMLMA0GCSqGSIb3DQEB
# BQUAMIGVMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQg
# TGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNV
# BAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTEdMBsGA1UEAxMUVVROLVVTRVJG
# aXJzdC1PYmplY3QwHhcNMTUxMjMxMDAwMDAwWhcNMTkwNzA5MTg0MDM2WjCBhDEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKjAoBgNVBAMT
# IUNPTU9ETyBTSEEtMSBUaW1lIFN0YW1waW5nIFNpZ25lcjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAOnpPd/XNwjJHjiyUlNCbSLxscQGBGue/YJ0UEN9
# xqC7H075AnEmse9D2IOMSPznD5d6muuc3qajDjscRBh1jnilF2n+SRik4rtcTv6O
# KlR6UPDV9syR55l51955lNeWM/4Og74iv2MWLKPdKBuvPavql9LxvwQQ5z1IRf0f
# aGXBf1mZacAiMQxibqdcZQEhsGPEIhgn7ub80gA9Ry6ouIZWXQTcExclbhzfRA8V
# zbfbpVd2Qm8AaIKZ0uPB3vCLlFdM7AiQIiHOIiuYDELmQpOUmJPv/QbZP7xbm1Q8
# ILHuatZHesWrgOkwmt7xpD9VTQoJNIp1KdJprZcPUL/4ygkCAwEAAaOB9DCB8TAf
# BgNVHSMEGDAWgBTa7WR0FJwUPKvdmam9WyhNizzJ2DAdBgNVHQ4EFgQUjmstM2v0
# M6eTsxOapeAK9xI1aogwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2Ny
# bC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0LmNybDA1BggrBgEF
# BQcBAQQpMCcwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20w
# DQYJKoZIhvcNAQEFBQADggEBALozJEBAjHzbWJ+zYJiy9cAx/usfblD2CuDk5oGt
# Joei3/2z2vRz8wD7KRuJGxU+22tSkyvErDmB1zxnV5o5NuAoCJrjOU+biQl/e8Vh
# f1mJMiUKaq4aPvCiJ6i2w7iH9xYESEE9XNjsn00gMQTZZaHtzWkHUxY93TYCCojr
# QOUGMAu4Fkvc77xVCf/GPhIudrPczkLv+XZX4bcKBUCYWJpdcRaTcYxlgepv84n3
# +3OttOe/2Y5vqgtPJfO44dXddZhogfiqwNGAwsTEOYnB9smebNd0+dmX+E/CmgrN
# Xo/4GengpZ/E8JIh5i15Jcki+cPwOoRXrToW9GOUEB1d0MYwggVeMIIERqADAgEC
# AhEAr+4nKCTVfrQKuecqlSuCzDANBgkqhkiG9w0BAQsFADB9MQswCQYDVQQGEwJH
# QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3Jk
# MRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RPIFJT
# QSBDb2RlIFNpZ25pbmcgQ0EwHhcNMTcwMzA2MDAwMDAwWhcNMTkwMzA2MjM1OTU5
# WjCBpzELMAkGA1UEBhMCREUxDjAMBgNVBBEMBTY2NTcxMREwDwYDVQQIDAhTYWFy
# bGFuZDESMBAGA1UEBwwJRXBwZWxib3JuMRkwFwYDVQQJDBBLb3NzbWFuc3RyYXNz
# ZSA3MSIwIAYDVQQKDBlLcsOkbWVyIElUIFNvbHV0aW9ucyBHbWJIMSIwIAYDVQQD
# DBlLcsOkbWVyIElUIFNvbHV0aW9ucyBHbWJIMIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEAtXAX07uZxJy76BLbjZV1v/5wtXYVFJBY7ZBWl7SyAnX+W6sv
# 8yOD8/3dmnCyMMtiRNxrXUsL86aCN7WaCnZWAHzzTn5Ufh7hhNX0lToZ7vACZPrx
# eC+54gYXRGYOmeAX9RGlLyUiUj7DVeE6wEqIKENh82ZhgSTAgzgz73RZE07NHJPH
# zToJt/lRwFdlqRqljf3m4tYf1kq5Hk0ZhXohhC0uQSVxS41SdrquFkq9u+4of0Iq
# ebk8Mx4HaAW0meq0ZqJOqXIwolDhejRG9r7Jn1M4dNmJoSVT/Q/qUu2Z/zTecEUB
# 3p83994+bpxk9ZrSkIdG45hsWaUqoo5l8SXulwIDAQABo4IBrDCCAagwHwYDVR0j
# BBgwFoAUKZFg/4pN+uv5pmq4z/nmS71JzhIwHQYDVR0OBBYEFG0gXsn66LifYENz
# rQE5f9+KwG+MMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMBEGCWCGSAGG+EIBAQQEAwIEEDBGBgNVHSAEPzA9MDsGDCsG
# AQQBsjEBAgEDAjArMCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8u
# bmV0L0NQUzBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNv
# bS9DT01PRE9SU0FDb2RlU2lnbmluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPgYI
# KwYBBQUHMAKGMmh0dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNvZGVT
# aWduaW5nQ0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5j
# b20wHQYDVR0RBBYwFIESaW5mb0BrcmFlbWVyLWl0LmRlMA0GCSqGSIb3DQEBCwUA
# A4IBAQCFrLIiBF54IWFm3kZhwqucckh4N30X9z8x2hTjdnFZRZXJmtAIRhEfvJ1+
# hV3UTOlFdk1x56AU4PiDY0gHYNaT972OlJQyXn1IAfvtCPaFIALAnYpYJLpwb1pK
# 8aAeX01cpaBIqPP4qPOnf9l4NRTZb4J/TSFM3vG13gGn8NvyBFp8lW2B9jX1Geh6
# xIzA/ehJ3eiaSCNMMeERdrEYf+PWNVVvMuLPqADNbLo1G6AoqNIDATUo94A/BJ3t
# XRw9vh8YBlD1brYtsa1xjelka1Kx191r265dhc4HqeJ9DbB6rw6TwSCARtbqL+6j
# 3p2zZtgBhbbAHRjF3vs8oCri0YjSMIIF2DCCA8CgAwIBAgIQTKr5yttjb+Af907Y
# WwOGnTANBgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdy
# ZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09N
# T0RPIENBIExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlv
# biBBdXRob3JpdHkwHhcNMTAwMTE5MDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBhTEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNVBAMT
# IkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCR6FSS0gpWsawNJN3Fz0RndJkrN6N9I3AAcbxT
# 38T6KhKPS38QVr2fcHK3YX/JSw8Xpz3jsARh7v8Rl8f0hj4K+j5c+ZPmNHrZFGvn
# nLOFoIJ6dq9xkNfs/Q36nGz637CC9BR++b7Epi9Pf5l/tfxnQ3K9DADWietrLNPt
# j5gcFKt+5eNu/Nio5JIk2kNrYrhV/erBvGy2i/MOjZrkm2xpmfh4SDBF1a3hDTxF
# YPwyllEnvGfDyi62a+pGx8cgoLEfZd5ICLqkTqnyg0Y3hOvozIFIQ2dOciqbXL1M
# GyiKXCJ7tKuY2e7gUYPDCUZObT6Z+pUX2nwzV0E8jVHtC7ZcryxjGt9XyD+86V3E
# m69FmeKjWiS0uqlWPc9vqv9JWL7wqP/0uK3pN/u6uPQLOvnoQ0IeidiEyxPx2bvh
# iWC4jChWrBQdnArncevPDt09qZahSL0896+1DSJMwBGB7FY79tOi4lu3sgQiUpWA
# k2nojkxl8ZEDLXB0AuqLZxUpaVICu9ffUGpVRr+goyhhf3DQw6KqLCGqR84onAZF
# dr+CGCe01a60y1Dma/RMhnEw6abfFobg2P9A3fvQQoh/ozM6LlweQRGBY84YcWsr
# 7KaKtzFcOmpH4MN5WdYgGq/yapiqcrxXStJLnbsQ/LBMQeXtHT1eKJ2czL+zUdqn
# R+WEUwIDAQABo0IwQDAdBgNVHQ4EFgQUu69+Aj36pvE8hI6t7jiY7NkyMtQwDgYD
# VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIB
# AArx1UaEt65Ru2yyTUEUAJNMnMvlwFTPoCWOAvn9sKIN9SCYPBMtrFaisNZ+EZLp
# LrqeLppysb0ZRGxhNaKatBYSaVqM4dc+pBroLwP0rmEdEBsqpIt6xf4FpuHA1sj+
# nq6PK7o9mfjYcwlYRm6mnPTXJ9OV2jeDchzTc+CiR5kDOF3VSXkAKRzH7JsgHAck
# aVd4sjn8OoSgtZx8jb8uk2IntznaFxiuvTwJaP+EmzzV1gsD41eeFPfR60/IvYcj
# t7ZJQ3mFXLrrkguhxuhoqEwWsRqZCuhTLJK7oQkYdQxlqHvLI7cawiiFwxv/0Cti
# 76R7CZGYZ4wUAc1oBmpjIXUDgIiKboHGhfKppC3n9KUkEEeDys30jXlYsQab5xoq
# 2Z0B15R97QNKyvDb6KkBPvVWmckejkk9u+UJueBPSZI9FoJAzMxZxuY67RIuaTxs
# lbH9qh17f4a+Hg4yRvv7E491f0yLS0Zj/gA0QHDBw7mh3aZw4gSzQbzpgJHqZJx6
# 4SIDqZxubw5lT2yHh17zbqD5daWbQOhTsiedSrnAdyGN/4fy3ryM7xfft0kL0fJu
# MAsaDk527RH89elWsn2/x20Kk4yl0MC2Hb46TpSi125sC8KKfPog88Tk5c0NqMuR
# krF8hey1FGlmDoLnzc7ILaZRfyHBNVOFBkpdn627G190MIIF4DCCA8igAwIBAgIQ
# LnyHzA6TSlL+lP0ct800rzANBgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0Ix
# GzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEa
# MBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0Eg
# Q2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTMwNTA5MDAwMDAwWhcNMjgwNTA4
# MjM1OTU5WjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRl
# ZDEjMCEGA1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCmmJBjd5E0f4rR3elnMRHrzB79MR2zuWJX
# P5O8W+OfHiQyESdrvFGRp8+eniWzX4GoGA8dHiAwDvthe4YJs+P9omidHCydv3Lj
# 5HWg5TUjjsmK7hoMZMfYQqF7tVIDSzqwjiNLS2PgIpQ3e9V5kAoUGFEs5v7BEvAc
# P2FhCoyi3PbDMKrNKBh1SMF5WgjNu4xVjPfUdpA6M0ZQc5hc9IVKaw+A3V7Wvf2p
# L8Al9fl4141fEMJEVTyQPDFGy3CuB6kK46/BAW+QGiPiXzjbxghdR7ODQfAuADcU
# uRKqeZJSzYcPe9hiKaR+ML0btYxytEjy4+gh+V5MYnmLAgaff9ULAgMBAAGjggFR
# MIIBTTAfBgNVHSMEGDAWgBS7r34CPfqm8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQU
# KZFg/4pN+uv5pmq4z/nmS71JzhIwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQI
# MAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYDVR0gBAowCDAGBgRVHSAA
# MEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0NPTU9E
# T1JTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHEGCCsGAQUFBwEBBGUwYzA7
# BggrBgEFBQcwAoYvaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQWRk
# VHJ1c3RDQS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNv
# bTANBgkqhkiG9w0BAQwFAAOCAgEAAj8COcPu+Mo7id4MbU2x8U6ST6/COCwEzMVj
# EasJY6+rotcCP8xvGcM91hoIlP8l2KmIpysQGuCbsQciGlEcOtTh6Qm/5iR0rx57
# FjFuI+9UUS1SAuJ1CAVM8bdR4VEAxof2bO4QRHZXavHfWGshqknUfDdOvf+2dVRA
# GDZXZxHNTwLk/vPa/HUX2+y392UJI0kfQ1eD6n4gd2HITfK7ZU2o94VFB696aSdl
# kClAi997OlE5jKgfcHmtbUIgos8MbAOMTM1zB5TnWo46BLqioXwfy2M6FafUFRun
# UkcyqfS/ZEfRqh9TTjIwc8Jvt3iCnVz/RrtrIh2IC/gbqjSm/Iz13X9ljIwxVzHQ
# NuxHoc/Li6jvHBhYxQZ3ykubUa9MCEp6j+KjUuKOjswm5LLY5TjCqO3GgZw1a6lY
# YUoKl7RLQrZVnb6Z53BtWfhtKgx/GWBfDJqIbDCsUgmQFhv/K53b0CDKieoofjKO
# Gd97SDMe12X4rsn4gxSTdn1k0I7OvjV9/3IxTZ+evR5sL6iPDAZQ+4wns3bJ9ObX
# wzTijIchhmH+v1V04SF3AwpobLvkyanmz1kl63zsRQ55ZmjoIs2475iFTZYRPAmK
# 0H+8KCgT+2rKVI2SXM3CZZgGns5IW9S1N5NGQXwH3c/6Q++6Z2H/fUnguzB9XIDj
# 5hY5S6cxggR7MIIEdwIBATCBkjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3Jl
# YXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01P
# RE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNpZ25pbmcg
# Q0ECEQCv7icoJNV+tAq55yqVK4LMMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSvDV3w9UgaTFiY
# qR7gQrH7yFmd/DANBgkqhkiG9w0BAQEFAASCAQCjC6vtfV2zndCvgU5SF0Khrrsr
# FdbgLhDoqNwZ/RYYJBFubIn/HkkpHFt8d+B8KkBYdqJe0CJpITzyS3T8RKl7YXaR
# lqzQ8z/mXtDtwHkpJTKgoCkqi+Gnm0w0WY70tDutDUwWHoAuQHUljVN7+KhXbEud
# NvZNW7tbWCv3N5XUfyXisgVJAA6yQfOmwgdNc3Q4ihqXElIneal9xD5mYyijXMe8
# A5MfIgr5foBSSIULM6ZhnlJP7220aIpmC5xscjGdzgKkV0wY9HQ2aNeD7r1GYoZQ
# u0PBXQ+YbWp4YLB0CiHZpSFhzC/d9+rHsqcv57/G5pM9ylY4smkYeeCOcufXoYIC
# QzCCAj8GCSqGSIb3DQEJBjGCAjAwggIsAgEBMIGpMIGVMQswCQYDVQQGEwJVUzEL
# MAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYDVQQKExVU
# aGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93d3cudXNlcnRy
# dXN0LmNvbTEdMBsGA1UEAxMUVVROLVVTRVJGaXJzdC1PYmplY3QCDxaI8DklXmOO
# aRQ5B+YzCzAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMTgwODMxMTIwMDM3WjAjBgkqhkiG9w0BCQQxFgQUN8uT
# fCJtwpTbebCV8N35Vcee0YowDQYJKoZIhvcNAQEBBQAEggEAYIxwJKixsZogn6yX
# +dKScFhs/L4r9DBay83jR0vF6XqEPwaPTEuVB5piAYpqlsvUJJxH2D9Avaki8qaM
# 49I6FiHZlERxMN+V0XcxoBjh6xkqT2VHI3x+Qjb+DKdzNDH/kDo7c8jzMsJLM69K
# aEnntjL+RV011s7tom4agIiOCh+BqwTZtmas/kCuic98bON28A4Q8NQcNGkMDID3
# mqPf+WsxBLFgW/4x8OqwrY0NxbokxCdFSwqeFX0qirdZnMV/IDGHgwVzCQ3Tk/IJ
# m14SjLCwQWi3SKyqchY5CklnwToKWmn8NVE19sCW7w1OvH12/hlb4Ry0t07QN52u
# 6FvsbQ==
# SIG # End signature block
