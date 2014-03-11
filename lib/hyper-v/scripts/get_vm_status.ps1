#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
. ([System.IO.Path]::Combine($presentDir, "utils\write_messages.ps1"))

try {
  $vm = Get-VM -Id $vm_id -ErrorAction "stop"
  $state = $vm.state
  $status = $vm.status
  } catch [Microsoft.HyperV.PowerShell.VirtualizationOperationFailedException] {
    $state = "not_created"
    $status = "Not Created"
  }
  $resultHash = @{
    state = "$state"
    status = "$status"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
