# Vagrant Windows Hyper-V Provider

Vagrant is a tool for building complete development environments, sandboxed in a virtual machine. It helps enforce good practices by encouraging the use of automation so that development environments are as close to production as possible.

Hyper-V provider is available by default in Vagrant with version 1.5 and up. This plugin is created to provide windows guest support for the Vagrant Hyper-V provider.


## Installation
Install Vagrant 1.5 (or higher)
http://www.vagrantup.com/downloads.html


Install plugin like so: 
vagrant plugin install vagrant-windows-hyperv

## Configuration settings specific to this plugin

### Sync Folder configuration

With Vagrant 1.5 SMB share is available by default and vagrant picks the most suitable
implementation for the providers.

You can even specify the following options

 :type

 :smb_id   Specify a unique share name, with which the network share will be available. By default vagrant will generate a smb_id if not specified.
 

For more information please visit the Vagrant Documentation.

```ruby
   # Mounts the host/path to guest/path and will have realtime sync
   config.vm.synced_folder 'host/path', "guest/path"
```
### VM Type
* Set the VM guest type 

```ruby
config.vm.guest = :windows
config.vm.provider "hyperv" do |hv, override|
  override.ssh.username = "vagrant"
end
```
### New RDP Command
* A new command vagrant rdp is introduced to connect to the Windows VM
` vagrant rdp `


### Provision Command
* Provision command works for Vagrant hyper-v with this plugin installed
` vagrant provision `


## Troubleshooting

### Remote PowerShell
Vagrant-Windows-HyperV uses remote PowerShell to communicate with the guest VMs, so the guest VMs should have WinRM service running and remote PowerShell running.

To Enable remote PowerShell in the guest.
Go to the guest VM, open a cmd terminal and type the following command
```
powershell Enable-PSRemoting –force
```
### Trustedhosts
With PowerShell being enabled in the remote VM, the host has to trust this guest to establish the connection.
One can add the guest IP under trustedhost. Here "*" can be used as a wildcard to trust all hosts, or replace the * with the IP address of the guest..

Type this command from an Administrator cmdshell prompt

`
powershell set-item wsman:\localhost\client\trustedhosts *
`

### SMB Share
There is a bug in the current vagrant release (1.5.1) you may run into collisions when you create shares. To avoid this, user smb_id option and make sure the share name does not collide with existing shares.

`   config.vm.synced_folder 'C:/test_sync_2', "C:/Users/vagrant/test_sync_2", :smb_id => "test_my_share" `
