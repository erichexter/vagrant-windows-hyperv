#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
. ([System.IO.Path]::Combine($presentDir, "utils\write_messages.ps1"))

try {
  $vm = Get-VM -Id $vm_id -ErrorAction "stop"
  $network = Get-VMNetworkAdapter  -VM $vm
  $ip_address = $network.IpAddresses[0]
  $resultHash = @{
    ip = "$ip_address"
  }
  Write-Output-Message $resultHash
}
catch {
  $errortHash = @{
    type = "PowerShellError"
    message = "Failed to obtain network info of VM $_"
  }
  Write-Error-Message $errortHash
}
