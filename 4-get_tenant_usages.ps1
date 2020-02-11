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

# Get Usage List for specific tenant
$itemsList = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${tenantId}/usages" -Headers $headers

# Save JSON usages info into a file
$itemsList | ConvertTo-Json -Depth 100 | Out-File "${tenantId}_usages.json"