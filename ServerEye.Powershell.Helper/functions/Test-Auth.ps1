function Test-Auth{
    Param(
        $AuthToken
    )
    if ($AuthToken) {
        return $AuthToken
    }elseif($Global:ServerEyeGlobalApiKey){
        return $Global:ServerEyeGlobalApiKey
    } elseif ($Script:ServerEyeLocalSession) {
        return $Script:ServerEyeLocalSession
    } elseif ($Global:ServerEyeGlobalSession) {
        return $Global:ServerEyeGlobalSession
    } else {
        throw "Cannot find a Server-Eye session to use. Please provide one with the CmdLet Connect-SESession."
    }

}