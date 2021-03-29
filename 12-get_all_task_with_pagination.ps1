#**************************************************************************************************************
# Copyright © 2019-2020 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# includes common functions, base configuration and basis API checks
. ".\0-init.ps1"

# The size of page for pagination
$pageSize = 10

# The first call with limiting output limit=${pageSize}, the same as
# $page = Invoke-RestMethod -Uri "${baseUrl}api/task_manager/v2/tasks?limit=${pageSize}" -Headers $headers
$page = Acronis-Get -Uri "api/task_manager/v2/tasks?limit=${pageSize}"

# The cursor to go to the next page
$after = $page.paging.cursors.after

# Pages counter
$pageNumber = [System.Int32]1

Write-Output "The page number ${pageNumber}."

# Loop to move through all pages
while ($after) {

	$pagingParams = @{limit = $pageSize; after = $after}

	# The call for the next page 	limit=${pageSize}&after=${after}, the same as
	# $page = Invoke-RestMethod -Uri "${baseUrl}api/task_manager/v2/tasks?limit=${pageSize}&after=${after}" -Headers $headers
	$page = Acronis-Get -Uri "api/task_manager/v2/tasks" -Body $pagingParams
	# The cursor to go to the next page
	$after = $page.paging.cursors.after

	$pageNumber = $pageNumber+1

	Write-Output "The page number ${pageNumber}."

  }

Write-Output "The tasks were paged to the end."