#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# Get personal_tenant_id for user.json
$tokenInfo = Get-Content "agent_installation_token.json" | ConvertFrom-Json
$token = $tokenInfo.token

.\Cyber_Protection_Agent_for_Windows_x64.exe --quiet --registration by-token --reg-token $token --reg-address $baseUrl