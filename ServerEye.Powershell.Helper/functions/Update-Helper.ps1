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
        $SEmod = Get-Module -ListAvailable -Name $SEModule
        $online = Find-Module -Name $SEModule -Repository PSGallery -ErrorAction Stop
        if($SEmod.Version.ToString() -ne $online.Version){
        Update-Module -Name $SEModule -force
        Remove-Module -Name $SEModule
        Uninstall-Module -Name $SEModule -RequiredVersion $SEmod.Version -Force
        Import-Module -Name $SEModule
        }
    }

}