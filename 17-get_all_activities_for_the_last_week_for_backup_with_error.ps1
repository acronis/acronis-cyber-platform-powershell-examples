#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get time -7 days ago and convert it to the format accepted by API
$weekAgo = (Get-Date).ToUniversalTime().AddDays(-7).ToString("yyyy-MM-ddT00:00:00Z")

# Get a list of activities
# Completed during the last 7 days - completedAt=gt(${weekAgo})
# with error - resultCode=error
# for backup - policyType=backup, the same as
# $allLastWeekActivities = Invoke-RestMethod -Uri "${baseUrl}api/task_manager/v2/activities?completedAt=gt(${weekAgo})&resultCode=error&policyType=backup" -Headers $headers
$allLastWeekActivities = Acronis-Get -Uri "api/task_manager/v2/activities?completedAt=gt(${weekAgo})&resultCode=error&policyType=backup"

# Save the JSON activities info into a file
$allLastWeekActivities | ConvertTo-Json -Depth 100 | Out-File "all_the_last_week_activities_backup_with_error.json"