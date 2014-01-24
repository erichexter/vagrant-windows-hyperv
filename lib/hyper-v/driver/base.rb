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

require "json"
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
          @output = nil
        end

        def execute(command, options)
          r = execute_powershell(command, options) do |type, data|
            process_output(type, data)
          end
          if success? and !@output.empty?
            JSON.parse(json_output)
          else
            # raise VagrantPlugins::HyperV::Subprocess::Error => @error_messages
          end
        end

        protected

        def json_output
          json_begin = false
          json_resp = []
          @output.split("\n").each do |line|
            json_begin = false if line.include?("===End-Output===")
            json_resp << line.gsub("\\'","\"") if json_begin
            json_begin = true if line.include?("===Begin-Output===")
          end
          json_resp.join()
        end

        def success?
          @error_messages.empty?
        end

        def process_output(type, data)
          if type == :stdout
            @output = data.gsub("\r\n", "\n")
          end
          if type == :stdin
            # $stdin.gets.chomp || ""
          end
          if type == :stderr
            @error_messages = data
          end
        end

        def clear_output_buffer
          @output = ""
          @error_messages = ""
        end

        def check_power_shell
          unless Vagrant::Util::Which.which('powershell')
            raise "Power Shell not found"
          end
        end

        def execute_powershell(path, options, &block)
          lib_path = Pathname.new(File.expand_path("../../scripts", __FILE__))
          path = lib_path.join(path).to_s.gsub("/", "\\")
          options = options || {}
          ps_options = []
          options.each do |key, value|
            ps_options << "-#{key}"
            ps_options << "'#{value}'"
          end
          clear_output_buffer
          command = ["powershell", "-NoProfile", "-ExecutionPolicy",
              "Bypass", path, ps_options, {notify: [:stdout, :stderr, :stdin]}].flatten
          Vagrant::Util::Subprocess.execute(*command, &block)
        end
      end
    end
  end
end
