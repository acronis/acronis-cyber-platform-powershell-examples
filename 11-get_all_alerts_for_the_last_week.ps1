#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get Unix time -7 days ago and convert to nanoseconds
$weekAgo = [System.Int64](Get-Date -Date (Get-Date).ToUniversalTime().AddDays(-7).ToString("yyyy-MM-ddT00:00:00Z") -UFormat %s)
$weekAgo = $weekAgo*1000000000

# Get a list of alerts, the same as
# $allLastWeekAlerts = Invoke-RestMethod -Uri "${baseUrl}api/alert_manager/v1/alerts?updated_at=gt(${weekAgo})&order=desc(created_at)" -Headers $headers
$allLastWeekAlerts = Acronis-Get -Uri "api/alert_manager/v1/alerts?updated_at=gt(${weekAgo})&order=desc(created_at)"

# Save the JSON alerts info into a file
$allLastWeekAlerts | ConvertTo-Json -Depth 100 | Out-File "all_the_last_week_alerts.json"