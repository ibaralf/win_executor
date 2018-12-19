# Powershell script to execute ruby test automation. Call this PS
# script in scheduler.
#
#  - Checks if a specific file exists
#  - If file is found, executes ruby rspec
#    If file is not found, nothing is executed
#  - After execution, file is moved to a history folder
#    and timestamped on the file name.
#  - Logs are saved in $LOGGER 
#
# History: 12/11/2018 created
#

$QE_DIR = $HOME + "\Documents\quality"
$TRIGGER_FILE = $HOME + "\Documents\quality\exec_loan.yml"
$HISTORY_DIR = $HOME + "\Documents\history"
$PS_LOGFILE_DIR = $HOME + "\tmp"
$PS_LOGFILE = "ps_qe.log"
$LOGGER = $PS_LOGFILE_DIR + "\" + $PS_LOGFILE

# Params: -Level, Log level (usually INFO, WARNING, ERROR)
#         -Msg, Message to log into the file
# Puts a log entry into the powershell execution log 
function Log {
    Param($Level, $Msg)
    $right_now = Get-Date -Format g
    "$Level $right_now : $Msg" | Out-File -FilePath $LOGGER -Append
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
    Move-TriggerFile
}
else {
    Log -Level "INFO" -Msg "No test found."
}

Exit 
    





