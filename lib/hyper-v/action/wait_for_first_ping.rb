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
require "timeout"
require "vagrant/util/subprocess"

module VagrantPlugins
  module HyperV
    module Action
      class WaitForFirstPing

        def initialize(app, env)
          @app  = app
        end

        def call(env)
          env[:result] = true
          # Wait until the Machine's responds for a Ping.
          # This is to ensure the machine is completely ready
           ssh_info = env[:machine].ssh_info
            env[:ui].info("Waiting for machine to respond")
            command = ["ping", ssh_info[:host]]
            begin
              Timeout.timeout(120) do
                begin
                  r = Vagrant::Util::Subprocess.execute(*command)
                  result = r.stdout.match(/Received = \d/).to_s
                  received_ping = result.split("=").last.to_i
                end until received_ping > 2
              end
            rescue Timeout::Error
              env[:result] = false # couldn't reach state in time
            end
          @app.call(env)
        end

      end
    end
  end
end
