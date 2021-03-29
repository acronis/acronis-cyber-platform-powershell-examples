#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get Root tenant_id for the API Client
$client = Get-Content "api_client.json" | ConvertFrom-Json
$tenantId = $client.tenant_id

# Get Usage List for specific tenant, the same as
# $itemsList = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${tenantId}/usages" -Headers $headers
$itemsList = Acronis-Get -Uri "api/2/tenants/${tenantId}/usages"

# Save JSON usages info into a file
$itemsList | ConvertTo-Json -Depth 100 | Out-File "${tenantId}_usages.json"