#Configurable options:

#Make sure the path exists or you will spam your list every time the script runs:
$path_to_notified_file = ".\db\pwnd_list.csv"

#users to check for breach
$user_list = ("test@example.com")

#SMTP settings:
$email_notify = $true
$from = "test@example.com"
$subject = "ATTN: Account was included in a data breach"
$body_html = "Hello,<br>It has been noticed by an automated system that your email address was included in the following data breaches:"
$body_signature = "<br>It is recomended you change your passwords on those systems<br><br>Thank you<br>I_script_stuff Notifier Bot<br>"

#email credentials enable tested on gmail. If you don't need credentials set $needs_email_creds to false.
$needs_email_creds = $false
#configure credential file for email password if needed:
$creds_path = ".\cred.txt"
#read-host -assecurestring | convertfrom-securestring | out-file $creds_path




#SMTP server to use
$smtp = "smtp.gmail.com"
$smtp_port = "587"

#process smtp credentials
$pass = get-content $creds_path | convertto-securestring
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "$from", $pass

#
#Functions that power the script
#
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

#
# Search and notify 
#
if(test-path $path_to_notified_file ) {
$already_found = get-content $path_to_notified_file 
} else {
$already_found = ""
echo "Warning: No file loaded for $path_to_notified_file If this is the first time running the script a file will be created."
sleep 1
}

foreach($email in $user_list) {
    if($result = get-breachedstatus $email $false) {
        $working_email_body = $body_html
		$act_on_notify = $false
		foreach($line in $result) {
		$service = $line.Name
        $breachdate = $line.breachdate
        $breach_record = "$email,$service,$breachdate"
			if($already_found -notcontains $breach_record) {
			echo "$breach_record"
			echo "$breach_record" >> $path_to_notified_file
				if($email_notify) {
				$act_on_notify = $true
				$working_email_body += "<br>" + $breach_record
				}
			}
		}
		$working_email_body += $body_signature
		if(($email_notify) -and ($act_on_notify)) {
			if($needs_email_creds) {
			Send-MailMessage -from $from -To "$email" -Subject $subject -bodyashtml($working_email_body) -smtpServer "$smtp" -port "$smtp_port" -credential $credentials -UseSsl
			$working_email_body
			} else {
			#Send-MailMessage -from $from -To "$email" -Subject $subject -bodyashtml($working_email_body) -smtpServer "$smtp" -port "$smtp_port"
			$working_email_body
			}
		}
	}
#lets not over spam
sleep 5
}