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

# This file reads the configuration from the Hyper-V Virtual Machine XML
# And import a new VM and set a correct VHDX file which is present in
# Virtual Hard Disk folder.


  param (
      [string]$vm_xml_config = $(throw "-vm_xml_config is required."),
      [string]$vhdx_path = $(throw "-vhdx_path is required.")
   )

  try {
    [xml]$vmconfig = Get-Content -Path  $vm_xml_config

    $vm_name = $vmconfig.configuration.properties.name.'#text'
    $processors = $vmconfig.configuration.settings.processors.count.'#text'

    function Get_unique_name($name) {
      Get-VM | ForEach-Object -Process {
        if ($name -eq $_.Name) {
          $name =  $name + "_1"
        }
      }
      return $name
    }

    do {
      $name = $vm_name
      $vm_name = Get_unique_name $name
    } while ($vm_name -ne $name)

    $memory = (Select-Xml -xml $vmconfig -XPath "//memory").node.Bank
    if ($memory.dynamic_memory_enabled."#text" -eq "True") {
        $dynamicmemory = $True
    }
    else {
        $dynamicmemory = $False
    }

    # Memory values need to be in bytes
    $MemoryMaximumBytes = ($memory.limit."#text" -as [int]) * 1MB
    $MemoryStartupBytes = ($memory.size."#text" -as [int]) * 1MB
    $MemoryMinimumBytes = ($memory.reservation."#text" -as [int]) * 1MB

    # Get the name of the virtual switch
    $switchname = (Select-Xml -xml $vmconfig -XPath "//AltSwitchName").node."#text"

    # Determine boot device
    Switch ((Select-Xml -xml $vmconfig -XPath "//boot").node.device0."#text") {
    "Floppy"    { $bootdevice = "floppy" }
    "HardDrive" { $bootdevice = "IDE" }
    "Optical"   { $bootdevice = "CD" }
    "Network"   { $bootdevice = "LegacyNetworkAdapter" }
    "Default"   { $bootdevice = "IDE" }
    } #switch

    # Define a hash map of parameter values for New-VM

     $vm_params = @{
       Name = $vm_name
       NoVHD = $True
       MemoryStartupBytes = $MemoryStartupBytes
       SwitchName = $switchname
       BootDevice = $bootdevice
       ErrorAction = "Stop"
    }

    # Create the VM using the values in the hash map

    $vm = New-VM @vm_params

    $notes = (Select-Xml -xml $vmconfig -XPath "//notes").node.'#text'

    # Set-VM parameters to configure new VM with old values

    $more_vm_params = @{
        ProcessorCount = $processors
        MemoryStartupBytes = $MemoryStartupBytes
    }

    If ($dynamicmemory) {
        $more_vm_params.Add("DynamicMemory",$True)
        $more_vm_params.Add("MemoryMinimumBytes",$MemoryMinimumBytes)
        $more_vm_params.Add("MemoryMaximumBytes", $MemoryMaximumBytes)
    }
    else {
      $more_vm_params.Add("StaticMemory",$True)
    }

    if ($notes) {
      $more_vm_params.Add("Notes",$notes)
    }

    # Set the values on the VM
    $vm | Set-VM @more_vm_params -Passthru

    # Add drives to the virtual machine
    $controllers = Select-Xml -xml $vmconfig -xpath "//*[starts-with(name(.),'controller')]"
    # A regular expression pattern to pull the number from controllers
    [regex]$rx="\d"

    foreach ($controller in $controllers) {
      $node = $controller.Node
      # Check for SCSI
      if ($node.ParentNode.ChannelInstanceGuid) {
         $ControllerType = "SCSI"
      }
      else {
         $ControllerType = "IDE"
      }

      $drives = $node.ChildNodes | where {$_.pathname."#text"}
      foreach ($drive in $drives) {
          #if drive type is ISO then set DVD Drive accordingly
          $driveType = $drive.type."#text"

          $addDriveParam = @{
            ControllerNumber = $rx.Match($controller.node.name).value
            Path = $vhdx_path
          }
          if ($drive.pool_id."#text") {
            $ResourcePoolName = $drive.pool_id."#text"
            $addDriveParam.Add("ResourcePoolname",$ResourcePoolName)
          }

          if ($drivetype -eq 'VHD') {
              $addDriveParam.add("ControllerType",$ControllerType)
              $vm | Add-VMHardDiskDrive @AddDriveparam
          }
      }
    }

    $vm_id = (Get-VM $vm_name).id.guid

    Write-Host "===Begin-Output==="
    Write-Host "{
      \'name\' : \'$vm_name\',
      \'id\' : \'$vm_id\'
    }"
    Write-Host "===End-Output==="
  }
  catch {
    Write-Host "===Begin-Error==="
    Write-Host "{
      \'error\' : \'Hyper-V Import failed $_\'
    }"
    Write-Host "===End-Error==="
    return
  }
