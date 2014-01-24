param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

$vm = Get-VM -Id $vm_id
$network = Get-VMNetworkAdapter  -VM $vm
$ip_address = $network.IpAddresses[0]
Write-Host "===Begin-Output==="
Write-Host "{
  \'ip\' : \'$ip_address\'
}"
Write-Host "===End-Output==="
