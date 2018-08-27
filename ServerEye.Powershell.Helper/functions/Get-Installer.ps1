<# 
.SYNOPSIS
Download the Server-Eye msi Files

.DESCRIPTION
Download the Server-Eye msi Files

.PARAMETER path
The path were the msi Files should be placed.


#>
function Get-Installer {

    [CmdletBinding()]
	Param (
		[string]
		$Path
    )
    
    if ($Path -eq "")
{
	$Path = (Resolve-Path .\).Path
}


    
        $SE_baseDownloadUrl = "https://occ.server-eye.de/download"
        $SE_cloudIdentifier = "se"
        $SE_vendor = "Vendor.ServerEye"
        
        $oldBack = $host.privatedata.ProgressBackgroundColor;
        $oldFore = $host.privatedata.ProgressForegroundColor;
    
        $host.privatedata.ProgressForegroundColor = "DarkGray";
        $host.privatedata.ProgressBackgroundColor = "Gray";
    
          $AsciiArt_ServerEye = @"
      ___                          ___         
     / __| ___ _ ___ _____ _ _ ___| __|  _ ___ 
     \__ \/ -_) '_\ V / -_) '_|___| _| || / -_)
     |___/\___|_|  \_/\___|_|     |___\_, \___|
                                      |__/     
"@
        Write-Host $AsciiArt_ServerEye -ForegroundColor DarkYellow

        Write-Host "  getting current Server-Eye version... " -NoNewLine
        $wc = new-object system.net.webclient
        $curVersion = $wc.DownloadString("$SE_baseDownloadUrl/$SE_cloudIdentifier/currentVersion")
        Write-Host "done" -ForegroundColor Green

        Write-Host "  current version: " -NoNewLine
        Write-Host "$curVersion" -ForegroundColor DarkGray
    
        Write-Host "  downloading ServerEye.Vendor... " -NoNewline
        DownloadSEFile "$SE_baseDownloadUrl/vendor/$SE_vendor/Vendor.msi"  "$Path/Vendor.msi"
        Write-Host "done" -ForegroundColor Green
    
        Write-Host "  downloading ServerEye.Core... " -NoNewline
        DownloadSEFile "$SE_baseDownloadUrl/$curVersion/ServerEye.msi" "$Path/ServerEye.msi"
        Write-Host "done" -ForegroundColor Green
    
    }

      function DownloadSEFile {
          [CmdletBinding()]
          Param (
              [string]
              $Url,
          
              [string]
              $TargetFile
          )
      
          try
          {
              $uri = New-Object "System.Uri" "$url"
              $request = [System.Net.HttpWebRequest]::Create($uri)
              $request.set_Timeout(15000) #15 second timeout
              $response = $request.GetResponse()
              $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
              $responseStream = $response.GetResponseStream()
              $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
              $buffer = new-object byte[] 10KB
              $count = $responseStream.Read($buffer, 0, $buffer.length)
              $downloadedBytes = $count
          
              while ($count -gt 0)
              {
                  $targetStream.Write($buffer, 0, $count)
                  $count = $responseStream.Read($buffer, 0, $buffer.length)
                  $downloadedBytes = $downloadedBytes + $count
                  Write-Progress -activity "Downloading file '$($url.split('/') | Select-Object -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength) * 100)
              }
          
              Write-Progress -activity "Finished downloading file '$($url.split('/') | Select-Object -Last 1)'" -Status "Done" -Completed
          
              $targetStream.Flush()
              $targetStream.Close()
              $targetStream.Dispose()
              $responseStream.Dispose()
          
          }
          catch
          {
          
              Write-Host -Message "Error downloading: $Url - Interrupting execution - $($_.Exception.Message)" -EventID 666 -EntryType Error
          }
      } 