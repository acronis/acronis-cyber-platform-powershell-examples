#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

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

# The request contains body with JSON
$headers.Add("Content-Type", "application/json")
$headers.Add("User-Agent", "ACP 1.0/Acronis Cyber Platform PowerShell Examples")