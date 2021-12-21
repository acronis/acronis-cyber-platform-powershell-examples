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

	# Find applied policies
	$appliedPolicies = Acronis-Get -Uri "/api/policy_management/v4/applications?context_id=${firstMachineResourceId}&policy_type=policy.protection.total"

	if ($null -ne $appliedPolicies.items -And $appliedPolicies.items.Length -gt 0  ){

		# Get the first applicable policy
		if ($null -ne $applicablePolicies.items[0].policy[0].parent_ids) {
			$appliedPoliciesFirstPolicyId = $applicablePolicies.items[0].policy[0].parent_ids[0]
		}
		else {
			$appliedPoliciesFirstPolicyId = $applicablePolicies.items[0].policy[0].id
		}

		# Revoke the first applicable policy to the first found machines
		# FOR DEMO PURPOSES ONLY
		Acronis-Delete -Uri "/api/policy_management/v4/applications?context_id=${firstMachineResourceId}&policy_id=${appliedPoliciesFirstPolicyId}"

	}
	else {

		Write-Host "No applicable policies available."
	}

}
else {

	Write-Host "No machines available."

}