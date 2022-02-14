#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get Root tenant_id for the API Client
$client = Get-Content "${scriptDir}\..\api_client.json" | ConvertFrom-Json
$tenantId = $client.tenant_id

# Body JSON to create a report
$json = @"
{
    "parameters": {
        "kind": "usage_summary",
        "tenant_id": "$tenantId",
        "level": "direct_partners",
        "formats": [
            "csv_v2_0"
        ],
        "show_skus": true,
        "hide_zero_usage": "false",
        "period": {
            "start": "2021-10-01",
            "end": "2021-10-31"
        }
    },
    "schedule": {
        "type": "once"
    },
    "result_action": "save"
}
"@

# Create a report, the same as
# $report = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/reports" -Headers $headers -Body $json
$report = Acronis-Post -Uri "api/2/reports" -Body $json

# Save JSON report info into a file
$reportId = $report.id
$report | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\${reportId}_report_for_tenant_${tenantId}_with_sku.json"

# A report is not produced momently, so we need to wait for it to become saved
# Here is a simple implementation for sample purpose expecting that
# For sample purposes we use 1 report from stored -- as we use once report
do {
  Start-Sleep -Seconds 1
  # Get the stored report, the same as
  # $storedReportInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/reports/${reportId}/stored" -Headers $headers
  $storedReportInfo = Acronis-Get -Uri "api/2/reports/${reportId}/stored"

} until ($storedReportInfo.items[0].status -eq "saved")

# For sample purposes we use 1 report from stored -- as we use once report
# MUST BE CHANGED if you want to deal with scheduled one or you have multiple reports
$storedReportId = $storedReportInfo.items[0].id

# Download the report
Invoke-WebRequest  -Uri "${baseUrl}api/2/reports/${reportId}/stored/${storedReportId}" -Headers $headers -OutFile "${scriptDir}\..\${storedReportId}_report_with_sku.csv"