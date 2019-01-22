# PowerShell script to execute Ruby
 Windows uses scheduler and PowerShell to execute jobs (similar to Unix CRON jobs). This uses a file to determine whether to run a ruby rspec test. If the specified file exists, the this PowerShell script will call 'bundle exec rspec some_spec_file`.
 
 # Adding to Windows Scheduler
 The scheduler essentially runs a job every set interval. Follow the steps to add your PS script to be executed every specified time frame.
 * Open Task Scheduler application - you can search it using the taskbar search 
 ![alt text](https://github.com/ibaralf/win_executor/blob/master/images/search_scheduler.jpg)
 * Click the Create Task option on the right side panel
 * In the General tab, Enter a name for your new task (e.g. run_per_minute)
 ![alt text](https://github.com/ibaralf/win_executor/blob/master/images/create_task.jpg)
 * In the Trigger tab, Click Repeat task every 5 minutes and duration indefinitely, Click OK
 ![alt text](https://github.com/ibaralf/win_executor/blob/master/images/trigger.jpg)
 * In the Action tab, Enter PowerShell.exe for program/script and the add arguments box, enter the full path and filename of your powershell script.
 ![alt text](https://github.com/ibaralf/win_executor/blob/master/images/action.jpg)
 * Save. Your task should now execute depending on the interval you specified
 * NOTE: The specified interval options are limited when creating the task trigger (ex. 5 minutes, 10 minutes, 30 minutes, 1 hour). If you need a more specific interval. Create the trigger with one of the options (ex. 10 minutes), then once the task is created, edit the trigger and enter the value you want (ex. 1 minute).
