function Get-CachedContainer {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        $ContainerID,
        [parameter(Mandatory = $false)]
        $AuthToken
    ) 
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        if (!$global:ServerEyeMAC) {
            $global:ServerEyeMAC = @()
        }
        if (!$global:ServerEyeCC) {
            $global:ServerEyeCC = @()
        }
    }

    Process {
        if ($global:ServerEyeCC.cid -eq $ContainerID) {
            Write-Debug "CC Container Caching"
            $Container = $global:ServerEyeCC | Where-Object {$_.cid -eq $ContainerID}
        }elseif ($global:ServerEyeMAC.cid -eq $ContainerID) {
            Write-Debug "MAC Container Caching"
            $Container = $global:ServerEyeMAC | Where-Object {$_.cid -eq $ContainerID}
        }else {
            Write-Debug "Container API Call"
            $Container = Get-SeApiContainer -cid $ContainerID -AuthToken $AuthToken
            if ($Container.type -eq 0) {
                $global:ServerEyeMAC += $container
            }else {
                $global:ServerEyeCC += $container
            }
        }
        return $Container
    }
    end {

    }
}
