#Using WUA to Scan for Updates Offline with PowerShell  
#VBS version: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/aa387290(v=vs.85)  
  
$Servicepath = Get-CimInstance -ClassName win32_service -Filter "Name like 'CCService'" | Select-Object PathName
$Path = $Servicepath.PathName -replace '"','' | Split-Path
$cab = Join-Path -Path $Path -ChildPath "brct\wsusscn2.cab"

$UpdateSession = New-Object -ComObject Microsoft.Update.Session  
$UpdateServiceManager  = New-Object -ComObject Microsoft.Update.ServiceManager  
$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$cab", 1)  
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()   
  
Write-Output "Searching for updates... `r`n"  
  
$UpdateSearcher.ServerSelection = 3 #ssOthers 
 
$UpdateSearcher.IncludePotentiallySupersededUpdates = $true # good for older OSes, to include Security-Only or superseded updates in the result list, otherwise these are pruned out and not returned as part of the final result list 
  
$UpdateSearcher.ServiceID = $UpdateService.ServiceID.ToString()  
  
$SearchResult = $UpdateSearcher.Search("IsInstalled=0") # or "IsInstalled=0 or IsInstalled=1" to also list the installed updates as MBSA did  
  
$Updates = $SearchResult.Updates  
  
if($Updates.Count -eq 0){  
    Write-Output "There are no applicable updates."  
    return $null  
}  
  
Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n"  
  
$i = 1
foreach($Update in $Updates){   
    [PSCustomObject]@{
        Number = $i
        Update = $Update.Title
    }
    $i ++
}

