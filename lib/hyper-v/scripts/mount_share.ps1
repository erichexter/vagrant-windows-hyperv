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
    [string]$share_name = $(throw "-share_name is required."),
    [string]$guest_path = $(throw "-guest_path is required."),
    [string]$guest_ip = $(throw "-guest_ip is required."),
    [string]$username = $(throw "-username is required."),
    [string]$password = $(throw "-password is required."),
    [string]$host_ip  = $(throw "-host_ip is required."),
    [string]$host_share_username  = $(throw "-host_share_username is required."),
    [string]$host_share_password  = $(throw "-host_share_password is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\create_session.ps1"
$modules += $presentDir + "\utils\write_messages.ps1"

forEach ($module in $modules) { . $module }

try {
    function Mount-File($share_name, $guest_path, $host_path, $host_share_username, $host_share_password) {
        try {
          # TODO: Check for folder exist.
          # Use net use and prompt for password
          $guest_path = $guest_path.replace("/", "\")
          # Map a network drive to the guest machine
          $result = net use * $host_path /user:$host_share_username $host_share_password /persistent:yes
          $mapped_drive = (($result -match "\w:") -split (" "))[1]
          Write-Host cmd /c  mklink /d $guest_path  $mapped_drive
          # If a folder exist remove it.
          if (!(Test-Path $guest_path)) {

          }
          cmd /c  mklink /d $guest_path  $mapped_drive
        } catch {
            return $_
        }
    }

    $response = Create-Remote-Session $guest_ip $username $password

    if (!$response["session"] -and $response["error"]) {
        Write-Error-Message $response["error"]
        return
    }
    $host_path = "\\$host_ip\$share_name"
    $host_share_username = "$host_ip\$host_share_username"
    $result = Invoke-Command -Session $response["session"] -ScriptBlock ${function:Mount-File} -ArgumentList $share_name, $guest_path, $host_path, $host_share_username, $host_share_password -ErrorAction "stop"
    Remove-PSSession -Id $response["session"].Id
    Write-Error-Message $result
}
catch {
    Write-Error-Message "Failed to mount files VM  $_"
    return
}
