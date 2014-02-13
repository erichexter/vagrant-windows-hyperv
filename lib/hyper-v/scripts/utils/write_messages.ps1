#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

function Write-Error-Message($message) {
  Write-Host "===Begin-Error==="
  Write-Host "{
    \'error\' : \'$message\'
  }"
  Write-Host "===End-Error==="
}

function Write-Output-Message($hash) {
  $result = @()
  forEach($key in $hash.keys) {
    $value = $hash.$key
    $result += "\'$key\' : \'$value\'"
  }
  $result = $result -join(" ,")
  Write-Host "===Begin-Output==="
  Write-Host "{
    $result
  }"
  Write-Host "===End-Output==="
}
