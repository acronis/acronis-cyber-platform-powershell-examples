#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get personal_tenant_id for user.json
$customer = Get-Content "customer.json" | ConvertFrom-Json
$customerTenantID = $customer.id

# Body JSON to create an installation token
$json = @"
{
	"tenant_id": "$customerTenantID",
	"expires_in": 3600,
	"scopes": [
	  "urn:acronis.com:tenant-id::backup_agent_admin"
	]
}
"@

# Issue an Agent registration token
# We use different base endpoint bc/api/account_server
# $token = Invoke-RestMethod -Method Post -Uri "${baseUrl}bc/api/account_server/registration_tokens" -Headers $headers -Body $json
$token = Acronis-Post -Uri "bc/api/account_server/registration_tokens" -Body $json

$token | ConvertTo-Json -Depth 100 | Out-File "agent_installation_token.json"