function get-breachedstatus() {
    Param(
        [Parameter(Mandatory = $true)][string]$email,
        [AllowEmptyString()]$brief_report="$true"
    )
    
    try{
        if($brief_report) {
        $url = "https://haveibeenpwned.com/api/v2/breachedaccount/" + $email + "?truncateresponse=true"
        } else {
        $url = "https://haveibeenpwned.com/api/v2/breachedaccount/" + $email
        }
    $result = invoke-restmethod "$url" -UserAgent "I_script_stuff checker 0.01"
    return $result
    } catch {
    return $false
    }
}

function get-pastestatus() {
    Param(
        [Parameter(Mandatory = $true)][string]$email
    )
    try{
    $url = "https://haveibeenpwned.com/api/v2/pasteaccount/" + $email
    $result = invoke-restmethod $url -UserAgent "I_script_stuff checker 0.01"
    return $result
    } catch {
    return $false
    }
}

function get-allbreaches() {
    try{
        $url = "https://haveibeenpwned.com/api/v2/breaches"
  
    $result = invoke-restmethod "$url" -UserAgent "I_script_stuff checker 0.01"
    return $result
    } catch {
    return $false
    }
}


function get-domainstatus() {
    Param(
        [Parameter(Mandatory = $true)][string]$domain,
    )
    try{
    $url = "https://haveibeenpwned.com/api/v2/breach/" + $domain
    $result = invoke-restmethod $url -UserAgent "I_script_stuff checker 0.01"
    return $result
    } catch {
    return $false
    }
}