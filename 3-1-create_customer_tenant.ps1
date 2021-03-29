#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get a partner info
$partner = Get-Content "partner.json" | ConvertFrom-Json
$partnerId = $partner.id

# Body JSON, to create a customer tenant
$json = @"
{
    "name": "Customer: PowerShell Examples v2.0",
    "parent_id": "${partnerId}",
    "kind": "${customerTenant}"
  }
"@

# Create a customer in a trial mode, the same as
# $customer = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/tenants" -Headers $headers -Body $json
$customer = Acronis-Post -Uri "api/2/tenants" -Body $json
$customerId = $customer.id

# Save the JSON customer info into a file
$customer | ConvertTo-Json -Depth 100 | Out-File "customer.json"

Enable-AllOfferingItems -BaseUrl $baseUrl -ParentTenantID $partnerId -TenantID $customerId -AuthHeader $headers -Edition $edition

# Switching customer tenant to production mode, the same as
# $customerPricing = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers
$customerPricing = Acronis-Get -Uri "api/2/tenants/${customerId}/pricing"
$customerPricing.mode = "production"

$customerPricingJson = $customerPricing | ConvertTo-Json

# Set production mode, the same as
# Invoke-RestMethod -Method Put -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers -Body $customerPricingJson
Acronis-Put -Uri "api/2/tenants/${customerId}/pricing" -Body $customerPricingJson