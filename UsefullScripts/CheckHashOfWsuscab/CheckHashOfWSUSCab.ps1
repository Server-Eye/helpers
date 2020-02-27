$SE_occServer = "occ.server-eye.de"
$SE_baseDownloadUrl = "https://$SE_occServer/download"
$SE_cloudIdentifier = "se"
$wc= new-object system.net.webclient
$SE_Version = $wc.DownloadString("$SE_baseDownloadUrl/$SE_cloudIdentifier/currentVersion")
$SE_Path = "C:\Program Files (x86)\Server-Eye\service"
$CABPath = "brct\Wsusscn2.cab"
$CABSHA1 = "34d15fa9a3af6a979f1917ddfa77baa4f44abff2"
$CABMD5 = "5ae1d9e29a96b6afcc585a291cae905a"


if (Test-Path -Path "$SE_Path\$SE_Version\$CABPath" ) {
    $SHA1 = get-filehash "$SE_Path\$SE_Version\$CABPath"-Algorithm SHA1
    $MD5 = get-filehash "$SE_Path\$SE_Version\$CABPath" -Algorithm MD5
    if ($cabsha1.hash -notlike ($sha1).ToUpper -or $cabMD5.hash -notlike ($MD5).ToUpper) {
        Write-Output "The Hashes og the WSUS Cab are wrong, maybe the File is older or newer"
    }else {
        Write-Output "It is the right wsusscn2.cab"
    }    
}elseif (Test-Path -Path "$SE_Path\1\$CABPath") {
    $SHA1 = get-filehash "$SE_Path\1\$CABPath"-Algorithm SHA1
    $MD5 = get-filehash "$SE_Path\1\$CABPath" -Algorithm MD5
    if ($cabsha1.hash -notlike ($sha1).ToUpper -or $cabMD5.hash -notlike ($MD5).ToUpper) {
        Write-Output "The Hashes og the WSUS Cab are wrong, maybe the File is older or newer"
    }else {
        Write-Output "It is the right wsusscn2.cab"
    }  
}else{
    Write-Output "Not Cab File found please check manually"
}




