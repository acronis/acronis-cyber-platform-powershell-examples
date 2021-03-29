#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get time -7 days ago and convert it to the format accepted by API
$weekAgo = (Get-Date).ToUniversalTime().AddDays(-7).ToString("yyyy-MM-ddT00:00:00Z")

# Get a list of tasks, the same as
# $allLastWeekTasks = Invoke-RestMethod -Uri "${baseUrl}api/task_manager/v2/tasks?completedAt=gt(${weekAgo})" -Headers $headers
$allLastWeekTasks = Acronis-Get -Uri "api/task_manager/v2/tasks?completedAt=gt(${weekAgo})"

# Save the JSON task info into a file
$allLastWeekTasks | ConvertTo-Json -Depth 100 | Out-File "all_the_last_week_tasks.json"