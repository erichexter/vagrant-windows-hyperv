#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
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
  # http://technet.microsoft.com/en-us/library/ff730951.aspx
  function Set-Acl-Rule($host_share_username) {
    $colRights = [System.Security.AccessControl.FileSystemRights]"Read, Modify, FullControl"

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

  # Set ACL for all files in the folder
  foreach ($file in $(Get-ChildItem $path -recurse)) {
    $acl = get-acl $file.FullName

    $permissions = Set-Acl-Rule $host_share_username
    $acl.SetAccessRule($permissions)

    # Write the changes to the object
    try {
      set-acl $File.Fullname $acl -ErrorAction stop
      } catch {

      }
    }

  $computer_name = $(Get-WmiObject Win32_Computersystem).name
  $grant_permission = "$computer_name\$host_share_username,Full"
  $result = net share $share_name=$path /unlimited /GRANT:$grant_permission
  if ($result -Match "$share_name was shared successfully.") {
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

