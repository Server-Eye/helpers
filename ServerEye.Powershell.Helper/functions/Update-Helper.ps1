<#
    .SYNOPSIS
    Updates the Helper or the Api Module.

    .PARAMETER Modulename
    The Name of the Module that should be Updatet.
#>

function Update-Helper {
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    $Modulename
)


        $module = Get-Module -ListAvailable -Name $Modulename -ErrorAction Stop -ErrorVariable errormodule
        $online = Find-Module -Name $Modulename -Repository PSGallery -ErrorAction Stop
        if(!$module){
        Install-Module -Name $Modulename -Scope CurrentUser -Force
        Import-Module -Name $Modulename
        }
        elseif($module.Version -ne $online.Version){
        Update-Module -Name $Modulename -force
        Remove-Module -Name $Modulename
        Uninstall-Module -Name $Modulename -RequiredVersion $module.Version 
        Import-Module -Name $Modulename
        }

}