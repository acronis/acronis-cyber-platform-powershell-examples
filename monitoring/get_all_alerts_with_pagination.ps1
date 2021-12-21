#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# The size of page for pagination
$pageSize = 10

# The first call with limiting output limit=${pageSize}, the same as
# $page = Invoke-RestMethod -Uri "${baseUrl}api/alert_manager/v1/alerts?limit=${pageSize}" -Headers $headers
$page = Acronis-Get -Uri "api/alert_manager/v1/alerts?limit=${pageSize}"

# The cursor to go to the next page
$after = $page.paging.cursors.after

# Pages counter
$pageNumber = [System.Int32]1

Write-Output "The page number ${pageNumber}."

# Loop to move through all pages in forward direction
while ($after) {

	$pagingParams = @{limit = $pageSize; after = $after}

	# The call for the next page 	limit=${pageSize}&after=${after}, the same as
	# $page = Invoke-RestMethod -Uri "${baseUrl}api/alert_manager/v1/alerts?limit=${pageSize}&after=${after}" -Headers $headers
	$page = Acronis-Get -Uri "api/alert_manager/v1/alerts" -Body $pagingParams

	# The cursor to go to the next page
	$after = $page.paging.cursors.after

	$pageNumber = $pageNumber+1

	Write-Output "The page number ${pageNumber}."
}

Write-Output "The alerts were paged to the end."

# The cursor to go to the previous page
$before = $page.paging.cursors.before

# Loop to move through all pages in backward direction
while ($before) {

	$pagingParams = @{limit = $pageSize; before = $before}

	# The call for the previous page 	limit=${pageSize}&before=${before}
	# $page = Invoke-RestMethod -Uri "${baseUrl}api/alert_manager/v1/alerts?limit=${pageSize}&before=${before}" -Headers $headers
	$page = Acronis-Get -Uri "api/alert_manager/v1/alerts" -Body $pagingParams

	# The cursor to go to the previous page
	$before = $page.paging.cursors.before

	$pageNumber = $pageNumber-1

	Write-Output "The page number ${pageNumber}."
}

Write-Output "The alerts were paged to the start."