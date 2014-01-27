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
          env[:ui].info('Setting up Folders Share')
          smb_shared_folders
          # prepare_smb_share
          # mount_shared_folders
          @app.call(env)
        end

        def smb_shared_folders
          {}.tap do |result|
            @env[:machine].config.vm.synced_folders.each do |id, data|
              # Ignore disabled shared folders
              next if data[:disabled]

              # Collect all SMB shares
              next unless data[:smb]

              # This to prevent overwriting the actual shared folders data
              result[id] = data.dup
            end
          end
        end

        def prepare_smb_share
          smb_shared_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            hostpath = hostpath.gsub("/", "\\")
            options = {:path => hostpath, :name => data[:share_name]}
            response = @env[:machine].provider.driver.execute('set_smb_share.ps1', options)
          end
        end

        # Use different mount commands when the guest is Windows or Linux
        def mount_shared_folders
          @env[:machine].communicate.sudo("ls")
        end

      end
    end
  end
end
