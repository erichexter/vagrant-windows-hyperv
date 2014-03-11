#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

function Write-Error-Message($message) {
  Write-Host "===Begin-Error==="
   Write-Host $message
  Write-Host "===End-Error==="
}

function Write-Output-Message($message) {
  Write-Host "===Begin-Output==="
  Write-Host $message
  Write-Host "===End-Output==="
}
