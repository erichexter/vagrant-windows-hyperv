#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

param (
    [string]$path = $(throw "-path is required."),
    [string]$share_name = $(throw "-share_name is required."),
    [string]$host_share_username = $(throw "-host_share_username is required")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

# Get a sample folder which has the required ACL (Access control)
# Use this as a template and assign the same access to the folders which are
# to be shared from Host to the Guest VM

try {
  function Set-Acl-Rule($host_share_username) {
    $colRights = [System.Security.AccessControl.FileSystemRights]"Read, Write"

    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None

    $objType =[System.Security.AccessControl.AccessControlType]::Allow
    $computer_name = $(Get-WmiObject Win32_Computersystem).name
    $objUser = New-Object System.Security.Principal.NTAccount("$computer_name\$host_share_username")

    return New-Object System.Security.AccessControl.FileSystemAccessRule `
        ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
  }

  # See all available shares and check alert user for existing / conflicting share name
  $shared_folders = net share
  $reg = "$share_name(\s+)$path(\s)"
  $existing_share = $shared_folders -Match $reg
  if ($existing_share) {
    # Always clear the existing share name and create a new one
    net share $share_name /delete /y
  }
  $result = net share $share_name=$path /unlimited
  if ($result -Match "$share_name was shared successfully.") {
    $acl = Get-Acl $path
    $objACE = Set-Acl-Rule $host_share_username
    $objACE = $acl.AddAccessRule($objACE)
    Set-Acl -Path $path -AclObject $acl
    $resultHash = @{
      message = "OK"
    }
    Write-Output-Message $resultHash
  } else {
    $reg = "^$share_name(\s+)"
    $existing_share = $shared_folders -Match $reg
    Write-Error-Message "Conflicting share name, A share name already exist $existing_share"
  }
} catch {
  Write-Error-Message $_
  return
}

