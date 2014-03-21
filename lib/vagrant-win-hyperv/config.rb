#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant"

module VagrantPlugins
  module HyperV
    class Config < Vagrant.plugin("2", :config)

      attr_accessor :guest, :ip_address_timeout

      def finalize!
        @guest = nil if @guest == UNSET_VALUE
        if @ip_address_timeout == UNSET_VALUE
          @ip_address_timeout = 120
        end
      end

      def initialize
        @gui = UNSET_VALUE
        @ip_address_timeout = UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        if (guest == UNSET_VALUE)
          errors << "Please mention the type of VM Guest"
        end
        { "HyperV" => errors }
      end

    end
  end
end
