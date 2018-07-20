[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
)

# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$result = @()

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {
                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                    foreach ($agent in $agents) {
                        $notifications = Get-SeApiAgentNotificationList -AuthToken $AuthToken -AId $agent.id

                        if ($notifications) {

                            foreach ($notification in $notifications) {
                                $out = New-Object psobject
                                $out | Add-Member NoteProperty Kunde ($customer.name)
                                $out | Add-Member NoteProperty Netzwerk ($container.name)
                                $out | Add-Member NoteProperty Server ($sensorhub.name)
                                $out | Add-Member NoteProperty Sensor ($agent.name)
                                if ($notification.isGroup -eq $true) {
                                    $out | Add-Member NoteProperty Benachrichtigung ($notification.surname)
                                } else {
                                    $out | Add-Member NoteProperty Benachrichtigung ($notification.useremail)
                                }
                                $out | Add-Member NoteProperty EMail ($notification.email)
                                $out | Add-Member NoteProperty SMS ($notification.phone)
                                $out | Add-Member NoteProperty Tanss ($notification.ticket)
                                $out | Add-Member NoteProperty Verzoegert ($notification.deferTime)
                                $result += $out

                            }


                        }
                    }
                }
            }
        }
    }
}
$result