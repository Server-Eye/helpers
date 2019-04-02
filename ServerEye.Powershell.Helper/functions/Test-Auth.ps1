function Test-Auth{
    Param(
        $AuthToken
    )
    if ($AuthToken) {
        return $AuthToken
    }elseif($Global:ServerEyeGlobalApiKey){
        $AuthToken = $Global:ServerEyeGlobalApiKey
        return $AuthToken
    } elseif ($Script:ServerEyeLocalSession) {
        return $Script:ServerEyeLocalSession
    } elseif ($Global:ServerEyeGlobalSession) {
        return $Global:ServerEyeGlobalSession
    } else {
        Write-Host -Message "Error: Cannot find a Server-Eye session to use. Please provide one in the request below." -ForegroundColor Red
        $AuthToken = Connect-SESession -persist
    }

}