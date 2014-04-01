#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "#{Vagrant::source_root}/plugins/providers/hyperv/provider"

module VagrantPlugins
  module VagrantHyperV
    class Provider < VagrantPlugins::HyperV::Provider

      def machine_id_changed
        @driver = Driver.new(@machine)
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        if Action.respond_to?(action_method)
          return Action.send(action_method)
        else
          super
        end
      end

    end
  end
end
