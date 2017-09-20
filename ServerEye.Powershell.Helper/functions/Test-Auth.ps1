function Test-Auth ($AuthToken) {
    if ($AuthToken) {
        return $AuthToken
    } elseif ($Script:ServerEyeLocalSession) {
        return $Script:ServerEyeLocalSession
    } elseif ($Global:ServerEyeGlobalSession) {
        return $Global:ServerEyeGlobalSession
    } else {
        Write-Error "Cannot find a Server-Eye session to use."
        ThrowError -ExceptionMessage "Cannot find a Server-Eye session to use." -ExceptionName "NoSession" -errorId 1 -errorCategory PermissionDenied
    }

}

