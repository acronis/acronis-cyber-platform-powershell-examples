#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# include common functions
. ".\0-basis-functions.ps1"

# Base URL for all requests -- replace with your own
# Here we expected that you are in the sandbox available from Acronis Developer Network Portal
$baseUrl = "https://dev-cloud.acronis.com/"

# check if token is valid ans renew if needed
if (-Not (Confirm-Token)) {
  $accessToken = Update-Token -BaseUrl $baseUrl
}
else {
  # Read an token info from file
  $token = Get-Content "api_token.json" | ConvertFrom-Json
  $accessToken = $token.access_token
}

# Manually construct Bearer
$bearerAuthValue = "Bearer $accessToken"
$headers = @{ "Authorization" = $bearerAuthValue }

# Get Root tenant_id for the API Client
$client = Get-Content "api_client.json" | ConvertFrom-Json
$clientId = $client.client_id

$apiClientInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/clients/${clientId}" -Headers $headers
$tenantId = $apiClientInfo.tenant_id

# Body JSON to create a report
$json = @"
{
    "parameters": {
        "kind": "usage_current",
        "tenant_id": "$tenantId",
        "level": "accounts",
        "formats": [
            "csv"
        ]
    },
    "schedule": {
        "type": "once"
    },
    "result_action": "save"
}
"@

# Add the request content type to the headers
$headers.Add("Content-Type", "application/json")

# Create a report
$report = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/reports" -Headers $headers -Body $json

# Save JSON report info into a file
$reportId = $report.id
$report | ConvertTo-Json -Depth 100 | Out-File "${reportId}_report_for_tenant_${tenantId}.json"

# A report is not produced momently, so we need to wait for it to become saved
# Here is a simple implementation for sample purpose expecting that
# For sample purposes we use 1 report from stored -- as we use once report
do {
  Start-Sleep -Seconds 1
  # Get the stored report
  $storedReportInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/reports/${reportId}/stored" -Headers $headers
} until ($storedReportInfo.items[0].status -eq "saved")

# For sample purposes we use 1 report from stored -- as we use once report
# MUST BE CHANGED if you want to deal with scheduled one or you have multiple reports
$storedReportId = $storedReportInfo.items[0].id

# Download the report
Invoke-WebRequest  -Uri "${baseUrl}api/2/reports/${reportId}/stored/${storedReportId}" -Headers $headers -OutFile "${storedReportId}_report.csv"