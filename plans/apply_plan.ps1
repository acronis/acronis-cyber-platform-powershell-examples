#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Request resources with type machines available for the current authorization scope
$allMachines = Acronis-Get -Uri "api/resource_management/v4/resources?type=resource.machine"

if ($null -ne $allMachines.items){

	# Get the first machine
	$firstMachine = $allMachines.items[0]
	$firstMachineResourceId = $firstMachine.id

	# Find applicable policy
	$applicablePolicies = Acronis-Get -Uri "/api/policy_management/v4/policies?applicable_to_context_id=${firstMachineResourceId}&type=policy.protection.total"

	if ($null -ne $applicablePolicies.items -And $applicablePolicies.items.Length -gt 0 ){

		# Get the first applicable policy
		if ($null -ne $applicablePolicies.items[0].policy[0].parent_ids) {
			$applicablePoliciesFirstPolicyId = $applicablePolicies.items[0].policy[0].parent_ids[0]
		}
		else {
			$applicablePoliciesFirstPolicyId = $applicablePolicies.items[0].policy[0].id
		}

		$json = @"
		{
            "policy_id": "${applicablePoliciesFirstPolicyId}",
            "context": {
                    "items": [
                            "${firstMachineResourceId}"
                            ]
                        }
        }
"@

		# Apply the first applicable policy to the first found machines
		# FOR DEMO PURPOSES ONLY
		Acronis-Post -Uri "/api/policy_management/v4/applications" -Body $json

	}
	else {

		Write-Host "No applicable policies available."
	}

}
else {

	Write-Host "No machines available."

}
