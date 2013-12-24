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

require "vagrant"
require_relative "putty/config"
module VagrantPlugins
  module HyperV
    class Config < Vagrant.plugin("2", :config)
      # If set to `true`, then VirtualBox will be launched with a GUI.
      #
      # @return [Boolean]
      attr_accessor :gui

      attr_reader :putty
      
      def putty_config(&block)
        block.call(@putty)
      end

      def finalize!        
        # @putty_private_key_path = nil if @putty_private_key_path == UNSET_VALUE
        @gui = nil if @gui == UNSET_VALUE
      end

      def initialize(region_specific=false)
        @gui = UNSET_VALUE
        @putty = Putty::Config.new
      end

      def validate(machine)
        errors = _detected_errors
        unless putty.valid_config?
          errors << putty.errors.flatten.join(" ")
        end
        { "HyperV" => errors }
      end

    end
  end
end
