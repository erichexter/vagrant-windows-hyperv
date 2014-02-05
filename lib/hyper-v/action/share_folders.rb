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
require "debugger"
require "vagrant/util/subprocess"
module VagrantPlugins
  module HyperV
    module Action
      class ShareFolders

        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env
          env[:ui].info('Setting up Folders Share, This process may take few minutes.')
          smb_shared_folders
          # FIXME:
          # Need to change the logic in how share folders are created in Windows
          # prepare_smb_share
          if env[:machine].config.vm.guest == :windows
            mount_shared_folders_to_windows
          elsif env[:machine].config.vm.guest == :linux
            mount_shared_folders_to_linux
          end
          @app.call(env)
        end

        def smb_shared_folders
          @smb_shared_folders = {}
          @env[:machine].config.vm.synced_folders.each do |id, data|
            # Ignore disabled shared folders
            next if data[:disabled]

            # Collect all SMB shares
            next unless data[:smb]
            # This to prevent overwriting the actual shared folders data
            @smb_shared_folders[id] = data.dup
          end
        end

        # FIXME:
        # Need to change the logic in how share folders are created in Windows
        def prepare_smb_share
          @smb_shared_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            options = {:path => hostpath, :name => data[:share_name]}
            command = ["net", "share", "#{data[:share_name]}=#{hostpath}"]
            @env[:machine].provider.driver.raw_execute(command)
          end
        end

        def mount_shared_folders_to_windows
          # Make the host trust the guest
          begin
            command = ["powershell", "Set-Item",  "wsman:\localhost\client\trustedhosts",  "*"]
            @env[:machine].provider.driver.raw_execute(command)
          rescue Error::SubprocessError => e
            @env[:ui].info e.message
          end
          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})

            ssh_info = @env[:machine].ssh_info
            @smb_shared_folders.each do |id, data|
              begin
              options = { :share_name => data[:share_name],
                          :guest_path => data[:guestpath],
                          :guest_ip => ssh_info[:host],
                          :username => ssh_info[:username],
                          :host_ip => result["host_ip"],
                          :password => @env[:machine].provider_config.guest.password }
              @env[:ui].info("Linking #{data[:share_name]} to Guest at #{data[:guestpath]} ...")
              @env[:machine].provider.driver.execute('mount_share.ps1', options)
            rescue Error::SubprocessError => e
              @env[:ui].info "Failed to link #{data[:share_name]} to Guest"
              @env[:ui].info e.message
            end
          end
        end

        def mount_shared_folders_to_linux

          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          host_share_username = @env[:machine].provider_config.host_share.username
          host_share_password = @env[:machine].provider_config.host_share.password

          @smb_shared_folders.each do |id, data|
            # Create a folder in /mnt with the share_name
            @env[:machine].communicate.sudo("mkdir -p /mnt/#{data[:share_name]}")

            # FIXME:
            # Set proper folder permissions and owner permissions
            # Change permissions set chmod to 644
            @env[:machine].communicate.sudo("chmod 644 /mnt/#{data[:share_name]}")

            # Mount the Network drive to Guest VM
            command  = "mount -t cifs //#{result["host_ip"]}/#{data[:share_name]}"
            command  += " -o username=#{host_share_username},pass=#{host_share_password},sec=ntlm /mnt/#{data[:share_name]}"
            @env[:machine].communicate.sudo(command)

            # Create a location in guest to guestpath
            @env[:machine].communicate.sudo("mkdir -p #{data[:guestpath]}")

            # Create a symlink from mount point to the actual location to guest path
            command = "ln -s /mnt/#{data[:share_name]} #{data[:guestpath]}"
            @env[:machine].communicate.sudo(command)
          end

        end
      end
    end
  end
end
