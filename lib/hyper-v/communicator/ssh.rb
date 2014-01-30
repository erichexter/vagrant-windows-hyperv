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

require "net/ssh"

module VagrantPlugins
  module HyperV
    module Communicator
      class SSH
        def initialize(machine)
          @machine = machine
          @connection = nil
        end

        def sudo(command)
          Net::SSH.start(ssh_info[:host], ssh_info[:username], connection_options) do |ssh|
            ssh.open_channel do |channel|
              channel.request_pty do |c, success|
                raise "could not request pty" unless success
                channel.exec  "sudo #{command}"
                channel.on_data do |c_, data|
                  if data.include?("[sudo] password for") || data.include?("Password for")
                    print data
                    input = $stdin.gets || ""
                    channel.send_data(input.chomp() + "\n")
                  end
                end
              end
            end
            ssh.loop
          end
        end

        protected

        def ssh_info
          @ssh_info ||= @machine.ssh_info
        end

        def connection_options
          opts = {
            :auth_methods          => ["none", "publickey", "hostbased", "password"],
            :config                => false,
            :forward_agent         => ssh_info[:forward_agent],
            :keys                  => [ssh_info[:private_key_path]],
            :keys_only             => true,
            :paranoid              => false,
            :port                  => ssh_info[:port],
            :user_known_hosts_file => []
          }
        end
      end
    end
  end
end
