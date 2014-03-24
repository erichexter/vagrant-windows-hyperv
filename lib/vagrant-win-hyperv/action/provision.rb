#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module VagrantHyperV
    module Action
      class Provision < Vagrant::Action::Builtin::Provision
        # Override this method from core vagrant, here we branch out the provision for windows
        def run_provisioner(env)
          if env[:machine].provider_config.guest == :windows
            case env[:provisioner].class.to_s
            when "VagrantPlugins::Shell::Provisioner"
              Provisioner::Shell.new(env).provision_for_windows
            when "VagrantPlugins::Puppet::Provisioner::Puppet"
              Provisioner::Puppet.new(env).provision_for_windows
            when "VagrantPlugins::Chef::Provisioner::ChefSolo"
              Provisioner::ChefSolo.new(env).provision_for_windows
            end
          else
            env[:provisioner].provision
          end
        end
      end
    end
  end
end
