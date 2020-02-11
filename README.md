# Base Acronis Cyber Platform API operations with PowerShell

PowerShell is a very powerful scripting tool which is suitable for many management tasks. It’s very popular for managing Microsoft infrastructure and with PowerShell Core, it can be used for Linux workloads. So let's look deeply at how to use PowerShell to solve common tasks with the Acronis Cyber Platform API.

## Create an API Client to access the API

A JWT token with a limited time to life approach is used to securely manage access of any API clients, like our scripts, for example, to the Acronis Cyber Cloud. Using login and password for a specific user is not a secure and manageable way to create a token, but technically it's possible. Thus we create an API client with a client id and a client secret to use as credentials to issue a JWT token.

To create an API Client we call the `/clients` end-point with POST request specifying in JSON body of the request a tenant we want to have access to. To authorize this the request, the Basic Authorization with user login and password for Acronis Cyber Cloud is used.
***
NOTE: In Acronis Cyber Cloud 9.0 an API Client credentials can be generated at the Management Portal.
***
NOTE: Normally, creating an API Client is a one-time process. As the API client is used to access the API, treat it as credentials and store securely. As well, do not store login and password in scripts itself.
***
In the following code block a login and a password are requested from a command line and a Basic Authorization header for HTTP requests are created.

```powershell
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
```

In those scripts it is expected that the [Acronis Developer Sandbox](https://developer.acronis.com/sandbox/) is used. It is available for registered developers at [Acronis Developer Network Portal](https://developer.acronis.com/). So the base URL for all requests (<https://dev-cloud.acronis.com/)> is used. Please, replace it with correct URL for your production environment if needed. For more details, please, review the [Authenticating to the platform via the Python shell tutorial](https://developer.acronis.com/doc/platform/management/v2/#/http/developer-s-guide/authenticating-to-the-platform-via-the-python-shell) from the Acronis Cyber Platform documentation.

For demo purposes, this script issues an API client for a tenant for a user for whom a login and a password are specified. You should add your logic as to what tenant should be used for an API Client creation.

```powershell
# Base URL for all requests -- replace with your own
# Here we expected that you are in the sandbox available from Acronis Developer Network Portal
$baseUrl = "https://dev-cloud.acronis.com/"

# The request contains body with JSON
$headers.Add("Content-Type", "application/json")

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
        "name": "PowerShell.App"
    }
}
"@

# Create an API Client
$client = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/clients" -Headers $headers -Body $json
```

Finally, we need to securely store the received credentials. For simplicity of the demo code, a simple JSON format is used. Please implement secure storage for your client credentials.

```powershell
# Save the API Client info to file for further usage
# YOU MUST STORE YOUR CREDENTIALS IN SECURE PLACE
# A FILE USES FOR CODE SIMPLICITY
$client | ConvertTo-Json -Depth 100 | Out-File "api_client.json"
```

## Issue a token to access the API

A `client_id` and a `client_secret` can be used to access the API using the Basic Authorization but it's not a secure way as we discussed above. It's more secure to have a JWT token with limited life-time and implement a renew/refresh logic for that token.

To issue a token `/idp/token` end-point is called using POST request with param `grant_type` equal `client_credentials` and content type `application/x-www-form-urlencoded` with Basic Authorization using a `client_id` as a user name and a `client_secret` as a password.

```powershell
# Read an API Client info from a file and store client_id and client_secret in variables
$client = Get-Content "api_client.json" | ConvertFrom-Json
$clientId = $client.client_id
$clientSecret = $client.client_secret

# Manually construct Basic Authentication Header
$pair = "${clientId}:${clientSecret}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ "Authorization" = $basicAuthValue }

# Base URL for all requests -- replace with your own
# Here we expected that you are in the sandbox available from Acronis Developer Network Portal
$baseUrl = "https://dev-cloud.acronis.com/"

# Use param to tell type of credentials we request
$postParams = @{ grant_type = "client_credentials" }

# Add the request content type to the headers
$headers.Add("Content-Type", "application/x-www-form-urlencoded")

$token = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/idp/token" -Headers $headers -Body $postParams
```

Finally, we need to securely store the received token. For simplicity of the demo code, the received JSON format is used. Please implement secured storage for your tokens.

```powershell
# Save the Token info to file for further usage
# YOU MUST STORE YOUR CREDENTIALS IN SECURE PLACE
# A FILE USES FOR CODE SIMPLICITY
# PLEASE CHECK TOKEN VALIDITY AND REFRESH IT IF NEEDED
$token | ConvertTo-Json -Depth 100 | Out-File "api_token.json"
```

A token has time-to-live and must be renewed/refreshed before expiration time. The best practice is to check before starting any API calls sequence and renew/refresh if needed. Assuming that the token stored in the JSON response format as above, it can be done using the following functions set.

`expires_on` is a time when the token will expire in Unix time format -- seconds from January 1, 1970. Here we assume that we will renew/refresh a token 15 minutes before the expiration time.

```powershell
# Check if the token valid at least 15 minutes
# Check if the token valid at least 15 minutes
function Confirm-Token {

  [CmdletBinding()]
  Param(
  )

  # Read an token info from
  $token = Get-Content "api_token.json" | ConvertFrom-Json

  $unixTime = $token.expires_on

  $expireOnTime = Convert-FromUnixDate -UnixTime $unixTime
  $timeDifference = New-TimeSpan -End $expireOnTime

  $timeDifference.TotalMinutes -gt 15
}

function Convert-FromUnixDate {

  [CmdletBinding()]
  Param(
    [parameter(Mandatory = $true)]
    [int]
    $UnixTime
  )

  [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixTime))
}

function Update-Token {

  [CmdletBinding()]
  Param(
    [parameter(Mandatory = $true)]
    [string]
    $BaseUrl
  )

  # Read an API Client info from a file and store client_idd and client_secret in variables
  $client = Get-Content "api_client.json" | ConvertFrom-Json
  $clientId = $client.client_id
  $clientSecret = $client.client_secret

  # Manually construct Basic Authentication Header
  $pair = "${clientId}:${clientSecret}"
  $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
  $base64 = [System.Convert]::ToBase64String($bytes)
  $basicAuthValue = "Basic $base64"
  $headers = @{ "Authorization" = $basicAuthValue }

  # Use param to tell type of credentials we request
  $postParams = @{ grant_type = "client_credentials" }

  # Add the request content type to the headers
  $headers.Add("Content-Type", "application/x-www-form-urlencoded")

  $token = Invoke-RestMethod -Method Post -Uri "${BaseUrl}api/2/idp/token" -Headers $headers -Body $postParams

  # Save the Token info to file for further usage
  # YOU MUST STORE YOUR CREDENTIALS IN SECURE PLACE
  # A FILE USES FOR CODE SIMPLICITY
  # PLEASE CHECK TOKEN VALIDITY AND REFRESH IT IF NEEDED
  $token | ConvertTo-Json -Depth 100 | Out-File "api_token.json"

  $token.access_token

}
```

## Create partner, customer and user tenants and set offering items

So now we can securely access the Acronis Cyber Platform API calls. In this topic we discuss how to create a partner, a customer tenants and enable for them all available offering items, and then create a user for the customer and activate the user by setting a password.

As it's mentioned above, we decided to enable all applications and offering items for both partner and customer tenants. Let's create a simple function to perform this task. Briefly, we take all available offering items for the parent tenant of the partner or the customer using GET request to `/tenants/${ParentTenantID}/offering_items/available_for_child` end-point with needed query parameters specifying `edition` and `kind` of the tenant. And finally, enabling this offering items for the partner or the customer using PUT request to `/tenants/${TenantID}/offering_items` end-point with all offering items JSON in the request body.

```powershell
# Enum for tenants kinds
enum Kind {
  root
  partner
  folder
  customer
  unit
}

# Simple function to enable all available offering items for child (partner or customer) tenant
function Enable-AllOfferingItems {

  [CmdletBinding()]
  Param(
    [parameter(Mandatory = $true)]
    [string]
    $BaseUrl,
    [parameter(Mandatory = $true)]
    [string]
    $ParentTenantID,
    [parameter(Mandatory = $true)]
    [string]
    $TenantID,
    [parameter(Mandatory = $true)]
    [System.Collections.IDictionary]
    $AuthHeader,
    [parameter(Mandatory = $false)]
    [string]
    $Edition = "standard",
    [parameter(Mandatory = $false)]
    [Kind]
    $Kind = "customer"
  )

  $queryParameters = @{ edition = $Edition; kind = $Kind }

  # Get Offering Items Available for the child tenants
  $response = Invoke-RestMethod -Uri "${BaseUrl}api/2/tenants/${ParentTenantID}/offering_items/available_for_child" -Headers $AuthHeader -Body $queryParameters
  # Take only array offering items
  $offeringItems = $response.items

  # The next API expected to have offering_items root
  # Thus create needed JSON structure using offering_items as a root
  $json = @{ offering_items = $offeringItems } | ConvertTo-Json -Depth 100

  # Enable all offering items for the partner
  Invoke-RestMethod -Method Put -Uri "${BaseUrl}api/2/tenants/${TenantID}/offering_items" -Headers $AuthHeader -Body $json

}
```

As we discussed above, before making a call to the actual API you need to ensure that an authorization token is valid. Please, use the functions like those described above to do it.

Assuming that we create the API client for our root tenant, we start from retrieving the API Client tenant information using GET request to `/clients/${clientId}` end-point. Then, using received `tenant_id` information as a parameter and `kind` equal to `partner`, we build a JSON body for POST request to `/tenants` end-point to create the partner. Next, we use previously described function `Enable-AllOfferingItems` to add applications and enable offering items. And as the final step do the same for a newly crated partner and create a customer for them.
***
NOTE: The following `kinds` of values are supported `root`, `partner`, `folder`, `customer`, `unit`.
***

```powershell
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
```

This is absolutely the same process as for a customer, the only difference is `kind` equal to `customer` in the request body JSON.

```powershell
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
```

By default customers are created in a trial mode. To switch to production mode we need to update customer pricing. To perform this task, we start from requesting current pricing using GET request to `/tenants/${customerId}/pricing` end-point then change `mode` property to `production` in the received JSON, then, finally, update the pricing using PUT request to `/tenants/${customerId}/pricing` end-point with a new pricing JSON.
***
NOTE: Please, be aware, that this switch is non-revertible.
***

```powershell
# Switching customer tenant to production mode
$customerPricing = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers
$customerPricing.mode = "production"

$customerPricingJson = $customerPricing | ConvertTo-Json

Invoke-RestMethod -Method Put -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers -Body $customerPricingJson
```

Finally, we create a user for the customer. At first we check if a login is available using GET request to `/users/check_login` end-point with `username` parameter set to an expected login. Then, we create a JSON body for POST request to `/users` end-point to create a new user.

```powershell
$userLogin = "MyFirstUser"
$userLoginParam = @{username=$userLogin}

$response = Invoke-WebRequest  -Uri "${baseUrl}api/2/users/check_login" -Headers $headers -Body $userLoginParam

# Check if login name is not used
if ($response.StatusCode -eq 204){

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
}
```

A created user is not active. To activate them we can either send them an activation e-mail or set them a password. The sending of an activation e-mail is the preferable way, as in this case a user can set their own password by themselves. We use a password way as for demo purposes a fake e-mail is used. To set a password we send a simple JSON and POST request to `/users/${userId}/password` end-point.

```powershell
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
```

At this point, we've created a partner, a customer, enable offering items for them, create a user and activate them.

## Get a tenant usage

A very common task is to check a tenant’s usage. It's quite a simple task. We just need to make a GET request to `/tenants/${tenantId}/usages` end-point, as result we receive a list with current usage information in JSON format.

```powershell
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
```

It's very useful to store usage information for further processing. In our example we use response JSON format to store it in a file.

```powershell
# Save JSON usages info into a file
$itemsList | ConvertTo-Json -Depth 100 | Out-File "${tenantId}_usages.json"
```

## Create and download simple report

The reporting capability of the Acronis Cyber Cloud gives you advanced capabilities to understand usage. In following simple example we create an one time report in csv format, and then download it. To check other options, please, navigate to the Acronis Cyber Platform [documentation](https://developer.acronis.com/doc/platform/management/v2/#/http/developer-s-guide/managing-reports).

To create a report we build a body JSON and make a POST request to `/reports` end-point. Then we look into stored reports with specified `$report.id` making a GET request to `/reports/${reportId}/stored` end-point.

```powershell
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
```

And finally we download created report using a GET request to `/reports/${reportId}/stored/${storedReportId}` and save it in `${storedReportId}_report.csv` file for further processing.

```powershell
# Download the report
Invoke-WebRequest  -Uri "${baseUrl}api/2/reports/${reportId}/stored/${storedReportId}" -Headers $headers -OutFile "${storedReportId}_report.csv"
```

## Summary

Now you know how to with the Acronis Cyber Platform API:

1. Create an API Client for the Acronis Cyber Platform API access
2. Issue a token for secure access for the API
3. Establish a simple procedure to renew/refresh the token
4. Create a partner and a customer tenants and enable offering items for them.
5. Create a user for a customer tenant and activate them.
6. Receive simple usage information for a tenant.
7. Create and download reports for usage.

Get started today, register on the [Acronis Developer Portal](https://developer.acronis.com/) and see the code samples available, also you can review solutions available in the [Acronis Cyber Cloud Solutions Portal](https://solutions.acronis.com/).

***
Copyright © 2019-2020 Acronis International GmbH. This is distributed under MIT license.
***
