#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get personal_tenant_id for user.json
$user = Get-Content "user.json" | ConvertFrom-Json
$userLogin = $user.login

# Body JSON to create an installation token
$json = @"
{
	"purpose": "user_login",
	"login": "$userLogin"
  }
"@

# Get an one time token, the same as
# $ott = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/idp/ott" -Headers $headers -Body $json
$ott = Acronis-Post -Uri "api/2/idp/ott" -Body $json

$ott | ConvertTo-Json -Depth 100 | Out-File "ott.json"

$ottValue = [System.Web.HTTPUtility]::UrlEncode($ott.ott)

Write-Output "${baseUrl}api/2/idp/external-login#ott=${ottValue}&targetURI=${baseUrl}mc/"
