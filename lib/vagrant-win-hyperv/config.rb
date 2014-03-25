#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant"

module VagrantPlugins
  module VagrantHyperV
    class Config < Vagrant.plugin("2", :config)

      attr_accessor :type

      def finalize!
        @type = nil if @type == UNSET_VALUE
      end

      def initialize
        @type = UNSET_VALUE
      end

      def validate(machine)
        errors = []
        if (!type)
          errors << "Please mention the type of VM Guest config.guest.type"
        end
        { "Hyper-V-Windows" => errors }
      end

    end
  end
end
