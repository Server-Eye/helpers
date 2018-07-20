[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [Switch]$AllAll
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
$culture =[Globalization.cultureinfo]::GetCultureInfo("de-DE")
$format = "yyyy-MM-ddHH:mm:ss"




$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

foreach ($customer in $customers) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id

    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {
           
            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id

                     foreach ($agent in $agents) {

                            $state = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $agent.id -Limit 1 -IncludeRawData "true" -IncludeHints "true"
                            $out = New-Object psobject
                            if ($state.raw.state -eq "Ok" -and $All.IsPresent -eq $true){
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $out | Add-Member NoteProperty Zustand ($state.raw.state)
                            $result +=$out 
                            }
                            if ($state.state -eq $true){
                            $out | Add-Member NoteProperty Kunde ($customer.name)
                            $out | Add-Member NoteProperty Netzwerk ($container.name)
                            $out | Add-Member NoteProperty Server ($sensorhub.name)
                            $out | Add-Member NoteProperty Sensor ($agent.name)
                            $out | Add-Member NoteProperty Zustand ($state.raw.state)
                            $result += $out 
                            if ($state.hintCount -eq "0" -and $state.raw.state -eq "Error"){
                            $out | Add-Member NoteProperty Status ("keine Hinweise")
                            $out | Add-Member NoteProperty Zeit ("")
                            $out | Add-Member NoteProperty Hinweis/Fehlerbeschreibung ("Kein Hinweiseingetragen")
                            $result += $out 
                            }
                            if ($state.hintCount -ne "0" -and $state.hints[0].hinttype -eq "0" -and $state.raw.state -eq "Error"){
                            $out | Add-Member NoteProperty Status ("in Behebung")
                            $datetmp = ($state.silencedUntil -replace("[a-zA-Z]", "")).Remove(18)
                            $date = [datetime]::ParseExact($datetmp,$format,$culture)
                            $out | Add-Member NoteProperty Zeit ($date)
                            $out | Add-Member NoteProperty Hinweis/Fehlerbeschreibung ($state.hints[0].message)
                            $result += $out 
                            }
                            if ($state.hintCount -ne "0" -and $state.hints[0].hinttype -eq "1" -and $state.raw.state -eq "Error"){
                            $out | Add-Member NoteProperty Status ("Nicht behoben")
                            $out | Add-Member NoteProperty Zeit ("")
                            $out | Add-Member NoteProperty Hinweis/Fehlerbeschreibung ($state.hints[0].message)
                            $result += $out 
                            }
                            if ($state.hintCount -ne "0" -and $state.hints[0].hinttype -eq "2" -and $state.raw.state -eq "Error"){
                            $out | Add-Member NoteProperty Status ("Fehlalarm")
                            $out | Add-Member NoteProperty Zeit ("")
                            $out | Add-Member NoteProperty Hinweis/Fehlerbeschreibung ($state.hints[0].message)
                            $result += $out 
                            }
                            if ($state.hintCount -ne "0" -and $state.hints[0].hinttype -eq "3" -and $state.raw.state -eq "Error"){
                            $out | Add-Member NoteProperty Status ("Hinweis")
                            $out | Add-Member NoteProperty Zeit ("")
                            $out | Add-Member NoteProperty Hinweis/Fehlerbeschreibung ($state.hints[0].message)
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
