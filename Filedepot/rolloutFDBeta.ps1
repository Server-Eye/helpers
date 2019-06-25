<# 
    .SYNOPSIS
    Script for the Filedepot Beta Rollout

    .DESCRIPTION
    Install the Data for the Filedepot Beta.

#>
[CmdletBinding()]
Param(
	$proxy = $null
)

$downloadpath = $env:ProgramData + "\ServerEye3\downloads"
$downloaduri = "http://share.server-eye.de/download/f7e0139ead7611db0db948dd144fedbf"


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
		Write-Host "System is 32 Bit an cant run the Filedepot"
	}
}

$progpath = Get-ProgramFilesDirectory 
$sepath = $progpath + "\Server-Eye\service"
$seconfig = $progpath +"\Server-Eye\config"

IF ((Test-Path ($sepath +"\902")) -eq $true){
    $servicepath =($sepath + "\902")
}elseif ((Test-Path ($sepath +"\1")) -eq $true) {
    $servicepath = $sepath + "\1"
}else{
    Write-Host "Not the newest Server-Eye Version installed."
}

function Get-SEFiles
{
	[CmdletBinding()]
	Param (
		[string]
		$BaseDownloadUrl,
		
		[string]
		$Path,

		$proxy
	)
	Get-SEFile -url "$downloaduri" -TargetFile "$Path\ServerEye.Filedepot.exe" -proxy $proxy
}

function Get-SEFile
{
	[CmdletBinding()]
	Param (
		[string]
		$Url,
		
		[string]
		$TargetFile,

		$proxy
	)
	
	try
	{
		$uri = New-Object "System.Uri" "$url"
		$request = [System.Net.HttpWebRequest]::Create($uri)
		$WebProxy = New-Object System.Net.WebProxy($proxy,$true)
		$request.proxy = $webproxy
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
		
		Write-Host "Cant Download the Data."
		Stop-Execution
	}
}

Write-Host "Downloading Filedepot EXE `n"
Get-SEFiles -BaseDownloadUrl $downloaduri -Path $downloadpath
Write-Host "Stopping Server-Eye Services `n"
Stop-Service -Name SE3Recovery -ErrorAction Stop
Stop-Service -Name MACService -ErrorAction Stop
Write-Host "Change Mac Config `n"
$mac = Get-Content -Path ($seconfig+"\se3_mac.conf") | Select-String "filedepotUpdateDisable=true"
if (!$mac) {
	Add-Content -Path ($seconfig+"\se3_mac.conf") -Value "filedepotUpdateDisable=true" -ErrorAction Stop
}
Write-Host "Copy Filedepot EXE `n"
$processold = get-process -Name ServerEye.Filedepot -ErrorAction SilentlyContinue
$processnew = get-process -Name FileDepot.core -ErrorAction SilentlyContinue
if($processold){
	Stop-Process -Name $processold.processname -Force
	Wait-Process -Name $processold.processname
	Copy-Item -Path $downloadpath\ServerEye.Filedepot.exe -Destination $servicepath\ServerEye.Filedepot.exe -ErrorAction Stop -Force
}elseif ($processnew) {
	Stop-Process -Name $processnew.processname -Force
	Wait-Process -Name $processnew.processname
	Copy-Item -Path $downloadpath\ServerEye.Filedepot.exe -Destination $servicepath\ServerEye.Filedepot.exe -ErrorAction Stop -Force
}else{
	Copy-Item -Path $downloadpath\ServerEye.Filedepot.exe -Destination $servicepath\ServerEye.Filedepot.exe -ErrorAction Stop -Force
}
Write-Host "Start Server-Eye Services `n"
Start-Service -Name SE3Recovery -ErrorAction Stop
Start-Service -Name MACService -ErrorAction Stop
