#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant"
require "#{Vagrant::source_root}/plugins/providers/hyperv/config"

module VagrantPlugins
  module VagrantHyperV
    class Config < VagrantPlugins::HyperV::Config

      attr_accessor :guest

      def finalize!
        super
        @guest = nil if @guest == UNSET_VALUE
      end

      def initialize
        super
        @guest = UNSET_VALUE
      end

      def validate(machine)
        super
        errors = _detected_errors
        if (guest == UNSET_VALUE)
          errors << "Please mention the type of VM Guest"
        end
        { "HyperV" => errors }
      end

    end
  end
end
