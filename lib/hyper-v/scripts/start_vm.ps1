param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )
 $vm = Get-VM -Id $vm_id
Start-VM $vm
