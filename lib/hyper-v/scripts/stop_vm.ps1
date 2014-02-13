#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

try {
  $vm = Get-VM -Id $vm_id -ErrorAction stop
  # Shuts down virtual machine regardless of any unsaved application data
  Stop-VM $vm -Force
  $resultHash = @{
    state = $vm.state
    status = $vm.status
  }
  Write-Output-Message $resultHash
}
catch {
  Write-Error-Message "Failed to stop a VM $_"
}
