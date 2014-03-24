#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "#{Vagrant::source_root}/plugins/providers/hyperv/provider"

module VagrantPlugins
  module VagrantHyperV
    class Provider < VagrantPlugins::HyperV::Provider

      def action(name)
        # Attempt to get the action specific for Hyper-V windows guest,
        # else give the control back to the super class
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
