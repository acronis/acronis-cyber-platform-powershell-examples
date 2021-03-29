#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get Root tenant_id for the API Client
$client = Get-Content "api_client.json" | ConvertFrom-Json
$clientId = $client.client_id

$apiClientInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/clients/${clientId}" -Headers $headers
$tenantId = $apiClientInfo.tenant_id

# Body JSON, to create a partner tenant
$json = @"
{
    "name": "Partner: PowerShell Examples v2.0",
    "parent_id": "${tenantId}",
    "kind": "${partnerTenant}"
  }
"@

# Create a partner, the same as
# $partner = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/tenants" -Headers $headers -Body $json
$partner = Acronis-Post -Uri "api/2/tenants" -Body $json
$partnerId = $partner.id

Enable-AllOfferingItems -BaseUrl $baseUrl -ParentTenantID $tenantId -TenantID $partnerId -AuthHeader $headers -Kind $partnerTenant -Edition $edition

# Save the JSON partner info into a file
$partner | ConvertTo-Json -Depth 100 | Out-File "partner.json"