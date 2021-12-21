#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# check if token is valid ans renew if needed
if (-Not (Confirm-Token)) {
	$accessToken = Update-Token -BaseUrl $baseUrl
  }
  else {

	# Read a customer scoped token if exists
	# WE DON'T CHECK EXPIRATION OR REISSUE IT
	# JUST DELETE IF THE ORIGINAL TOKEN EXPIRES
	if (Test-Path -Path "${scriptDir}\..\api_token_customer_scope.json" -PathType Leaf) {

		$token = Get-Content "${scriptDir}\..\api_token_customer_scope.json" | ConvertFrom-Json
		$accessToken = $token.access_token
	}
	else{
		# Read an token info from file
		$token = Get-Content "${scriptDir}\..\api_token.json" | ConvertFrom-Json
		$accessToken = $token.access_token
	}
  }

# Manually construct Bearer
$bearerAuthValue = "Bearer $accessToken"
$headers = @{ "Authorization" = $bearerAuthValue }

# The request contains body with JSON
$headers.Add("Content-Type", "application/json")
$headers.Add("User-Agent", "ACP 3.0/Acronis Cyber Platform PowerShell Examples")