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
require "log4r"
module VagrantPlugins
  module HyperV
    module Action
        class StopInstance
            def initialize(app, env)
              @app    = app
            end

            def call(env)
                hyperv_server = env[:hyperv_connection].find_vm_by_id(env[:machine].id)
                env[:ui].info('Stopping the Machine')
                hyperv_server.stop
            end
        end
    end
  end
end
