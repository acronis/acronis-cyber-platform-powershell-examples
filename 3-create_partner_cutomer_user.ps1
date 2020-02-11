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

# Body JSON, to create a partner tenant
$json = @"
{
    "name": "MyFirstPartner",
    "parent_id": "${tenantId}",
    "kind": "partner"
  }
"@

# The request contains body with JSON
$headers.Add("Content-Type", "application/json")

# Create a partner
$partner = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/tenants" -Headers $headers -Body $json
$partnerId = $partner.id

Enable-AllOfferingItems -BaseUrl $baseUrl -ParentTenantID $tenantId -TenantID $partnerId -AuthHeader $headers -Kind "partner"

# Body JSON, to create a customer tenant
$json = @"
{
    "name": "MyCustomer",
    "parent_id": "${partnerId}",
    "kind": "customer"
  }
"@

# Create a customer in a trial mode
$customer = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/tenants" -Headers $headers -Body $json
$customerId = $customer.id

Enable-AllOfferingItems -BaseUrl $baseUrl -ParentTenantID $partnerId -TenantID $customerId -AuthHeader $headers

# Switching customer tenant to production mode
$customerPricing = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers
$customerPricing.mode = "production"

$customerPricingJson = $customerPricing | ConvertTo-Json

Invoke-RestMethod -Method Put -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers -Body $customerPricingJson

$userLogin = "MyFirstUser"
$userLoginParam = @{username = $userLogin }

$response = Invoke-WebRequest  -Uri "${baseUrl}api/2/users/check_login" -Headers $headers -Body $userLoginParam

# Check if login name is free
if ($response.StatusCode -eq 204) {

  # Body JSON, to create a user
  $json = @"
{
  "tenant_id": "${customerId}",
  "login": "${userLogin}",
  "contact": {
      "email": "${userLogin}@example.com",
      "firstname": "Firstname",
      "lastname": "Lastname"
  }
}
"@

  $user = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/users" -Headers $headers -Body $json
  $userId = $user.id

  # Body JSON, to assign a password and activate the user
  # NEVER STORE A PASSWORD IN PLAIN TEXT FILE
  # THIS CODE IS FOR API DEMO PURPOSES ONLY
  # AS IT USES FAKE E-MAIL AND ACTIVATION E-MAIL CAN'T BE SENT
  $json = @"
{
  "password": "MyStrongP@ssw0rd"
}
"@

  Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/users/${userId}/password" -Headers $headers -Body $json

}