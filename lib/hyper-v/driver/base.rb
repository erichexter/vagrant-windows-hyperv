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

require "vagrant/util/which"
require "vagrant/util/subprocess"

module VagrantPlugins
  module HyperV
    module Driver
      class Base
        attr_reader :vmid

        def initialize(id=nil)
          @vmid = id
          check_power_shell
        end

        def import(options)
          r = execute_powershell("import_vm.ps1", options)
          puts r.stderr
        end

        def check_power_shell
          unless Vagrant::Util::Which.which('powershell')
            raise "Power Shell not found"
          end
        end

        protected
        def execute_powershell(path, options)
          lib_path = Pathname.new(File.expand_path("../../scripts", __FILE__))
          path = lib_path.join(path).to_s.gsub("/", "\\")
          debugger
          options = options || {}
          ps_options = []
          options.each do |key, value|
            ps_options << "-#{key}"
            ps_options << "'#{value}'"
          end
          command = ["powershell", "-NoProfile", "-ExecutionPolicy",
              "Bypass", path, ps_options].flatten
          debugger
          Vagrant::Util::Subprocess.execute(*command)
        end
      end
    end
  end
end
