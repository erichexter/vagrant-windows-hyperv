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
          prepare_smb_share
          if env[:machine].config.vm.guest == :windows
            mount_shared_folders
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

        def prepare_smb_share
          @smb_shared_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            options = {:path => hostpath, :name => data[:share_name]}
            command = ["net", "share", "#{data[:share_name]}=#{hostpath}"]
            @env[:machine].provider.driver.raw_execute(command)
          end
        end

        # Use different mount commands when the guest is Windows or Linux
        def mount_shared_folders
          # Make the host trust the guest
          command = ["powershell", "Set-Item",  "wsman:\localhost\client\trustedhosts",  "*"]
          @env[:machine].provider.driver.raw_execute(command)

          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})

          ssh_info = @env[:machine].ssh_info
          @smb_shared_folders.each do |id, data|
            options = { :share_name => data[:share_name],
                        :guest_path => data[:guestpath],
                        :guest_ip => ssh_info[:host],
                        :username => ssh_info[:username],
                        :host_ip => result["host_ip"],
                        :password => "happy" }
            @env[:ui].info("Linking #{data[:share_name]} to Guest at #{data[:guestpath]} ...")
            @env[:machine].provider.driver.execute('mount_share.ps1', options)
          end
        end

        def mount_shared_folders_to_linux
          # FIXME
          # Remove this class once the sudoers is fixed in Linux
          # All sudo commands need not prompt for password.
          communicate = Communicator::SSH.new(@env[:machine])
          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          @smb_shared_folders.each do |id, data|
            # Create a folder in /mnt with the share_name
            communicate.sudo("mkdir -p /mnt/#{data[:share_name]}")
            # Mount the Network drive to Guest VM
            command  = "sudo mount -t cifs //#{result["host_ip"]}/#{data[:share_name]}"
            command  += " -o username='#{result["host_name"]}',sec=ntlm /mnt/#{data[:share_name]}"
            communicate.sudo(command)
          end

        end
      end
    end
  end
end
