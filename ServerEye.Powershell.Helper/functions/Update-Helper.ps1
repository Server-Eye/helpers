<#
    .SYNOPSIS
    Updates the Helper and the Api Module.

#>

function Update-Helper {
    [CmdletBinding()]
    Param(

    )

    $SEModule = @("Servereye.powershell.helper")
   
    $SEmod = Get-Module -ListAvailable -Name $SEModule
    $online = Find-Module -Name $SEModule -Repository PSGallery -ErrorAction Stop
    if ($SEmod.Version.ToString() -ne $online.Version) {
        Update-Module -Name $SEMod -AcceptLicense -Force
        Remove-Module -Name $SEMod
        Uninstall-Module -Name $SEMod -RequiredVersion $SEmod.Version -Force
        Import-Module -Name $SEMod
    }

}