#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$path = $(throw "-path is required."),
    [string]$vm_id = $(throw "-vm_id is required."),
    [string]$guest_ip = $(throw "-guest_ip is required."),
    [string]$username = $(throw "-guest_username is required."),
    [string]$password = $(throw "-guest_password is required.")
)

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
$modules += $presentDir + "\utils\create_session.ps1"
forEach ($module in $modules) { . $module }

try {
  function Remote-Execute($path) {
    $old = Get-ExecutionPolicy
    Set-ExecutionPolicy Unrestricted -force
    . $path
    Set-ExecutionPolicy $old -force
  }

  $response = Create-Remote-Session $guest_ip $username $password
  if (!$response["session"] -and $response["error"]) {
      Write-Error-Message $response["error"]
      return
  }
  Invoke-Command -Session $response["session"] -ScriptBlock ${function:Remote-Execute} -ArgumentList $path -ErrorAction "stop"
} catch {
  Write-Error-Message "Failed to copy file  $_"
  return
}
