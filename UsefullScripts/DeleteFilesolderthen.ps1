<#
.SYNOPSIS
  Name: DeleteFilesolderthen.ps1
  The purpose of this script is delete all Files or Folders form a Path older than X Days.
  A list of all files and folders will be created onder C:\ProgramData\ServerEye3\ScriptOutput\RemovesviaScript.txt

#>

<#
<version>2</version>
<description>Deletes all Files or Folders older than X Days</description>
#>

Param ( 
[Parameter()] 
[String]$Path,
[int32]$OlderthanDays ,
[switch]$RemoveDirectorys
)

#region LoadingLibs
#load the libraries from the Server Eye directory
$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)
#endregion LoadingLibs
#region define all Variable
$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

#Define the exit Code
$exitCode = -1

$DatetoDelete = (Get-Date).AddDays("-$OlderthanDays")
$OutPutFile = "C:\ProgramData\ServerEye3\ScriptOutput\RemovesviaScript.txt"

#endregion define all Variable

#region Create Output File
if (!(Test-Path -Path C:\ProgramData\ServerEye3\ScriptOutput\)) {
  New-Item -Path C:\ProgramData\ServerEye3\ -Name ScriptOutput -ItemType Directory
  New-Item -Path C:\ProgramData\ServerEye3\ScriptOutput\ -Name RemovesviaScript.txt -ItemType File
}
#endregion Create Output File

#Check if Parameter is given
if(!$Path -or $Time){
    $msg.AppendLine("Please fill out all params needed for this script.")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
}else {
  try {
    #Check if RemoveDirectorys Parameter is Set
    if ($RemoveDirectorys.IsPresent -eq $true) {
      #Removes all Files form the Path
      $files = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } 
      $files | Out-File OutPutFile
      $files | Remove-Item -Recurse -ErrorAction Stop

      #Removes all Folders form the Path
      $Directorys = Get-ChildItem -Path $Path -Directory -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } 
      $Directorys | Add-Content -Path OutPutFile
      $Directorys | Remove-Item -Recurse -ErrorAction Stop

      $msg.AppendLine("All Files and folders older than $DatetoDelete where Removed")
      $exitCode = 1
      $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
    }else {
      #Removes all Files form the Path
      $files = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } 
      $files | Out-File -Path $OutPutFile
      $files | Remove-Item -Recurse -ErrorAction Stop

      $msg.AppendLine("All Files older than $DatetoDelete where Removed")
      $exitCode = 0
      $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
    }
  }
  catch {
    $msg.AppendLine("$_")
    $exitCode = 6
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
  }
}
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode