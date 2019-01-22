# Powershell script to execute ruby test automation. Call this PS
# script in scheduler.
# NOTE: powershell-yaml module needs to be installed. Run Install-Module powershell-yaml
#
#  - Checks if a specific file exists
#  - If file is found, executes ruby rspec
#    If file is not found, nothing is executed
#  - After execution, file is moved to a history folder
#    and timestamped on the file name.
#  - Logs are saved in $LOGGER 
#
# History: 12/11/2018 created
#           1/03/2019 Added YAML read and POST req for result 
#

import-module powershell-yaml

$QE_DIR = $HOME + "\Documents\quality"
$TRIGGER_FILE = $HOME + "\Documents\quality\exec_loan.yml"
$HISTORY_DIR = $HOME + "\Documents\history"
$PS_LOGFILE_DIR = $HOME + "\tmp"
$PS_LOGFILE = "ps_qe.log"
$LOGGER = $PS_LOGFILE_DIR + "\" + $PS_LOGFILE
$borrower_email = ''
$user_id = ''
$loan_id = ''
$response_url = ''

# Params: -Level, Log level (usually INFO, WARNING, ERROR)
#         -Msg, Message to log into the file
# Puts a log entry into the powershell execution log 
function Log {
    Param($Level, $Msg)
    $right_now = Get-Date -Format g
    "$Level $right_now : $Msg" | Out-File -FilePath $LOGGER -Append
}
# Reads the trigger file, containing created the loan ID and borrower email
# TODO: Avoid YAML module by simply opening and parsing data since this only
#       contains little data.
function ReadYAML {
    $file_content = Get-Content $TRIGGER_FILE
    $content = ''
    foreach ($line in $file_content) { $content = $content + "`n" + $line }
    $yaml = ConvertFrom-YAML $content
    $global:borrower_email = $yaml[':email']
    $global:user_id = $yaml[':user_id']
    $global:loan_id = $yaml[':loan_id']
    $global:staging_url = $yaml[':staging_url']
    $global:response_url = $yaml[':response_url']
}


function Post-Application-Result {
    $params = @{"borrower_email"= $global:borrower_email;
    "user_id" = $global:user_id;
    "loan_id" = $global:loan_id;
    "callback_id" = "post_application_result";
    "staging_url" = $global:staging_url;
    "response_url" = $global:response_url
    }
    Log -Level "INFO" -Msg "POST Req $params"
    $resp = Invoke-WebRequest -Uri http://localhost:80/slack_post -Method POST -Body ($params|ConvertTo-Json) -ContentType "application/json"
    Log -Level "INFO" -Msg "Response: $resp"
}

# Checks if powershell execution log exists, creates it if
# it doesn't exist
function CheckCreate-Log {
    if(!(Test-Path -Path $PS_LOGFILE_DIR )) {
        New-Item -ItemType directory -Path $PS_LOGFILE_DIR
    }
    if(!(Test-Path -Path $LOGGER )) {
        New-Item -path $PS_LOGFILE_DIR -name $PS_LOGFILE -type "file"
        "QE Tools: Created at $right_now" | Out-File -FilePath $LOGGER -Append
    }
    if(!(Test-Path -Path $HISTORY_DIR )) {
        New-Item -ItemType directory -Path $HISTORY_DIR
    }
}

function Move-TriggerFile {
    $right_now = Get-Date -Format s
    $tfile = "exec_loan_" + $right_now.Replace(':','_') + ".yml"
    $move_item = $TRIGGER_FILE
    $dest_item = $HISTORY_DIR + "\" + $tfile
    Move-Item -Path $move_item -Destination $dest_item
    Log -Level "INFO" -Msg "Archiving exec file to $dest_item"
}


#### M A I N
CheckCreate-Log

if ((Test-Path -Path $TRIGGER_FILE)) {
    Log -Level "INFO" -Msg "Executing bp_loan_spec.rb"
    Set-Location -Path $QE_DIR
    bundle exec rspec spec/bp_loan_spec.rb
    ReadYAML
    Post-Application-Result
    Move-TriggerFile
}
else {
    Log -Level "INFO" -Msg "No test found."
}

Exit 
    





