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
    [string]$host_ip  = $(throw "-host_ip is required.")
 )

try {
    function Get-Remote-Session($guest_ip, $username, $password) {
        $secstr = convertto-securestring -AsPlainText -Force -String $password
        $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
        New-PSSession -ComputerName $guest_ip -Credential $cred -ErrorAction "stop"
    }

    function Mount-File($share_name, $guest_path, $host_path) {
      # TODO: Check for folder exist.
      # Use net use and prompt for password
      $guest_path = $guest_path.replace("/", "\")
      cmd /c  mklink /d $guest_path  $host_path
    }

    $session = ""
    $count = 0
    $session_error = ""
    do {
        $count++
        try {
            $session = Get-Remote-Session $guest_ip $username $password
            $session_error = ""
        }
        catch {
            Start-Sleep -s 1
            $session_error = $_
            $session = ""
        }
    }
    while (!$session -and $count -lt 2)
    if (!$session -and $count -eq 2) {
        Write-Host "===Begin-Error==="
        Write-Host "{
          \'error\' : \'$session_error\'
        }"
        Write-Host "===End-Error==="
        return
    }
    $host_path = "\\$host_ip\$share_name"
    Invoke-Command -Session $session -ScriptBlock ${function:Mount-File} -ArgumentList $share_name, $guest_path, $host_path -ErrorAction "stop"
    Remove-PSSession -Id $session.Id
}
catch {
    Write-Host "===Begin-Error==="
    Write-Host "{
      \'error\' : \'Failed to mount files VM $_\'
    }"
    Write-Host "===End-Error==="
}
