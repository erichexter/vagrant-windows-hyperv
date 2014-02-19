# Vagrant Hyper-V Provider
A Vagrant provider for Hyper-V, Use vagrant commands for Virtual Machines created using Hyper-V

# Configuration

## Windows to Windows Configuration
When the guest virtual machine is windows, follow the following configurations

* A new command vagrant rdp is introduced to connect to the Windows VM
` vagrant rdp `

### VagrntFile needs the following changes.
- Set the type of VM guest
```ruby
  config.vm.guest = :windows
```
- Configure Virtual machine's credentials, if this block is not specified the default will be assumed (username vagrant and password vagrant)
```ruby
config.vm.provider "hyperv" do |hv|
  # Username and Password of Guest VM
  hv.guest_config do |config|
    config.username = ""  # Specify the VM username here
    config.password = "" # Specify the VM password here
  end
  ....
  ....
end
```

- Set the WinRM trusted host certificate configuration
Type this command from a cmd Administrator terminal
`powershell set-item wsman:\localhost\client\trustedhosts *`

- Sync Folder configuration

```ruby
   # Mounts the host/path to guest/path and will have realtime sync
   config.vm.synced_folder 'host/path', "guest/path", smb: true
   # Copies the content from host/path to guest once on vagrant up / vagrant reload
   config.vm.synced_folder 'host/path', "guest/path"
```


## Windows to Linux Configuration
When the guest virtual machine is linux, follow the following configurations
### VagrntFile needs the following changes.
- Set the type of VM guest
```ruby
  config.vm.guest = :linux
```

- Configure Virtual machine's credentials, if this block is not specified the default will be assumed (username vagrant and password vagrant)
```ruby
config.vm.provider "hyperv" do |hv|
  ...
  hv.guest_config do |config|
    config.username = ""  # Specify the VM username here
    config.password = "" # Specify the VM password here
  end
  ...
end
```

- Configure the credentials of a local user account created in the host.
This account is used to share folders between host and the VM
```ruby
config.vm.provider "hyperv" do |hv|
  ...
  hv.host_config do |share|
    share.username = ""
    share.password = ""
  end
  ...
end
```

- Sync Folder configuration

```ruby
   # Mounts the host/path to guest/path and will have realtime sync
   config.vm.synced_folder 'host/path', "guest/path", smb: true, :share_name => unique_share_name
   # Copies the content from host/path to guest once on vagrant up / vagrant reload
   config.vm.synced_folder 'host/path', "guest/path"
```
