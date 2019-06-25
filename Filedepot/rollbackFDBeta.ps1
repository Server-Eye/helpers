<# 
    .SYNOPSIS
    Script for the Filedepot Beta Rollout

    .DESCRIPTION
    Install the Data for the Filedepot Beta.

#>
[CmdletBinding()]
Param(
)

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
$seconfig = $progpath +"\Server-Eye\config"

$mac = Get-Content -Path ($seconfig+"\se3_mac.conf")
if ($mac -contains "filedepotUpdateDisable=true" ) {
	Write-Host "Change Mac Config `n"
	$mac.replace("filedepotUpdateDisable=true","") | Out-File ($seconfig+"\se3_mac.conf")
	Write-Host "Restart Server-Eye OCC Connector Service `n"
	Restart-Service -Name MACService
}else{
	Write-Host "No Change need"
}

