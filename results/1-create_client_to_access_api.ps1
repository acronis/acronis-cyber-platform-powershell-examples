#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# include base configuration
. ".\0-basis-configuration.ps1"

# Get credentials from command line input
$cred = (Get-Credential).GetNetworkCredential()

# Use Login and Password to create an API client
$login = $cred.UserName
$password = $cred.Password

# Manually construct Basic Authentication Header
$pair = "${login}:${password}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ "Authorization" = $basicAuthValue }

# The request contains body with JSON
$headers.Add("Content-Type", "application/json")
$headers.Add("User-Agent", "Training/1.0 Acronis #CyberFit Developers Business Automation Training")

# Get Self information to have tenant_id
$myInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/users/me" -Headers $headers
$tenantId = $myInfo.tenant_id

# Body JSON, to request an API Client for the $tenantId
$json = @"
{
    "type": "agent",
    "tenant_id": "$tenantId",
    "token_endpoint_auth_method": "client_secret_basic",
    "data": {
        "client_name": "PowerShell.App"
    }
}
"@

# Create an API Client
$client = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/clients" -Headers $headers -Body $json

# Save the API Client info to file for further usage
# YOU MUST STORE YOUR CREDENTIALS IN SECURE PLACE
# A FILE USES FOR CODE SIMPLICITY
$client | ConvertTo-Json -Depth 100 | Out-File "api_client.json"