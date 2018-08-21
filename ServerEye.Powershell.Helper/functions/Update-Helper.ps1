<#
    .SYNOPSIS
    Updates the Helper and the Api Module.

#>

function Update-Helper {
[CmdletBinding()]
Param(

)

    $SEModules = @("Servereye.powershell.helper","Servereye.powershell.api")
    foreach ($SEModule in $SEModules){
        $SEmod = Get-Module -ListAvailable -Name $SEModule -ErrorAction Stop -ErrorVariable errormodule
        $online = Find-Module -Name $SEModule -Repository PSGallery -ErrorAction Stop
        if(!$SEmod){
        Install-Module -Name $SEModule -Scope CurrentUser -Force
        Import-Module -Name $SEModule
        }
        elseif($SEmod.Version.ToString() -ne $online.Version){
        Update-Module -Name $SEModule -force
        Remove-Module -Name $SEModule
        Uninstall-Module -Name $SEModule -RequiredVersion $module.Version 
        Import-Module -Name $SEModule
        }
    }

}