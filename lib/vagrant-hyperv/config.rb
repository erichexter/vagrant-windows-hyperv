#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "vagrant"
require "#{Vagrant::source_root}/plugins/providers/hyperv/config"

module VagrantPlugins
  module VagrantHyperV
    class Config < VagrantPlugins::HyperV::Config

      attr_reader :customizations

      def customize(*command)
        event   = command.first.is_a?(String) ? command.shift : "pre-boot"
        command = command[0]
        options = command[1]
        @customizations << [event, command, options]
        super
      end

      def initialize(region_specific=false)
        @customizations   = []
        super
      end

      def validate(machine)
        core_hyperv_error = super
        errors = core_hyperv_error["Hyper-V"]

        valid_events = ["pre-boot"]
        @customizations.each do |event, _|
          if !valid_events.include?(event)
            errors << "Invalid custom event #{event} use pre-boot"
          end
        end

        { "HyperV" => errors }
      end

    end
  end
end
