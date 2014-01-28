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
require "log4r"
require "vagrant/util/subprocess"
require "vagrant/util/which"

module VagrantPlugins
  module HyperV
    module Action
      class SyncFolders

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_hyperv::action::sync_folders")
        end

        def call(env)
          return if env[:machine].config.vm.guest != :linux

          @app.call(env)
          ssh_info = env[:machine].ssh_info

          if ssh_info.nil?
            env[:ui].info('SSH Info not available, Aborting Sync folder')
            return
          end

          putty_private_key = env[:machine].provider_config.putty.private_key_path
          unless Vagrant::Util::Which.which('pscp')
            env[:ui].warn("PSCP Not found in host")
            return
          end
          env[:machine].config.vm.synced_folders.each do |id, data|

            # Ignore disabled shared folders
            next if data[:disabled] || data[:smb]

            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]
            env[:ui].info('Starting Sync folders')
            command = ["pscp", "-r", "-i", "#{putty_private_key}", hostpath,
              "#{ssh_info[:username]}@#{ssh_info[:host]}:#{guestpath}", {timeout: 10, notify: ['stdout']}]
            begin
              r = Vagrant::Util::Subprocess.execute(*command)
            rescue Vagrant::Util::Subprocess::TimeoutExceeded
              env[:ui].info('Sync Process timed out')
            end
            # TODO:
            # Check for error state when command fails
          end
        end
      end
    end
  end
end
