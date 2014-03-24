#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant"
require "#{Vagrant::source_root}/plugins/providers/hyperv/config"
require "debugger"

module VagrantPlugins
  module VagrantHyperV
    class Config < VagrantPlugins::HyperV::Config

      attr_accessor :guest

      def finalize!
        @guest = nil if @guest == UNSET_VALUE
        super
      end

      def initialize
        @guest = UNSET_VALUE
        super
      end

      def validate(machine)
        core_errors = super
        errors = core_errors["Hyper-V"] if core_errors["Hyper-V"]
        if (!guest)
          errors << "Please mention the type of VM Guest"
        end
        { "Hyper-V" => errors }
      end

    end
  end
end
