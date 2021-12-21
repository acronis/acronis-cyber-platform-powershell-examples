#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"


# Get time -7 days ago and convert it to the format accepted by API
$weekAgo = (Get-Date).ToUniversalTime().AddDays(-7).ToString("yyyy-MM-ddT00:00:00Z")

# Get a list of activities, the same as
# $allLastWeekActivities = Invoke-RestMethod -Uri "${baseUrl}api/task_manager/v2/activities?completedAt=gt(${weekAgo})" -Headers $headers
$allLastWeekActivities = Acronis-Get -Uri "api/task_manager/v2/activities?completedAt=gt(${weekAgo})"

# Save the JSON activities info into a file
$allLastWeekActivities | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\all_the_last_week_activities.json"