#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get personal_tenant_id for user.json
$user = Get-Content "${scriptDir}\..\user.json" | ConvertFrom-Json
$userTenantID = $user.personal_tenant_id

# Body JSON to create an installation token
$json = @"
{
	"expires_in": 3600,
	"scopes": [
	  "urn:acronis.com:tenant-id::backup_agent_admin"
	]
}
"@

# Issue an Agent registration token
# We use different base endpoint bc/api/account_server
# $token = Invoke-RestMethod -Method Post -Uri "${baseUrl}bc/api/account_server/registration_tokens" -Headers $headers -Body $json
# obsloete -> $token = Acronis-Post -Uri "bc/api/account_server/registration_tokens" -Body $json
$token = Acronis-Post -Uri "api/2/tenants/${userTenantID}/registration_tokens" -Body $json

$token | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\agent_installation_token.json"