#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get Root tenant_id for the API Client
$client = Get-Content "${scriptDir}\..\api_client.json" | ConvertFrom-Json
$clientId = $client.client_id

$apiClientInfo = Invoke-RestMethod  -Uri "${baseUrl}api/2/clients/${clientId}" -Headers $headers
$tenantId = $apiClientInfo.tenant_id

$tenantName  = Read-Host  -Prompt "Enter expected a customer tenant name"

# Body JSON, to create a partner tenant
$json = @"
{
    "name": "${tenantName}",
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
$partner | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\partner.json"