#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get a customer info
$customer = Get-Content "customer.json" | ConvertFrom-Json
$customerId = $customer.id

$userLogin = Read-Host  -Prompt "Enter expected username"
$email = Read-Host  -Prompt "Enter a correct e-mail, it will be used to activate created account"
$userLoginParam = @{username = $userLogin }

# Check if user login available, WebRequest is used as the answer has empty body
$response = Invoke-WebRequest -Uri "${baseUrl}api/2/users/check_login" -Headers $headers -Body $userLoginParam


# Check if login name is free
if ($response.StatusCode -eq 204) {

# Body JSON, to create a user
  $json = @"
{
  "tenant_id": "${customerId}",
  "login": "${userLogin}",
  "contact": {
      "email": "$email",
      "firstname": "First Name",
      "lastname": "Last Name"
  }
}
"@

  # Create a user, the same as
  # $user = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/users" -Headers $headers -Body $json
  $user = Acronis-Post -Uri "api/2/users" -Body $json
  $userId = $user.id

  # Save the JSON user info into a file
  $user | ConvertTo-Json -Depth 100 | Out-File "user.json"

  # Send an activation e-mail
  Acronis-Get -Uri "api/2/users/${userId}/send-activation-email"

}
else {
  Write-Host $response
  Write-Host "Can't create a new user. A user with this login already exists."
}