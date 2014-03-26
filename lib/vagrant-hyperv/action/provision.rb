#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "#{Vagrant::source_root}/lib/vagrant/action/builtin/provision"

module Vagrant
  module Action
    module Builtin
      class Provision

        alias_method :original_run_provisioner, :run_provisioner
        # Override this method from core vagrant, here we branch out the provision for windows
        def run_provisioner(env)
          if env[:machine].config.vm.guest == :windows
            case env[:provisioner].class.to_s
            when "VagrantPlugins::Shell::Provisioner"
              VagrantPlugins::VagrantHyperV::Provisioner::Shell.new(env).provision_for_windows
            when "VagrantPlugins::Puppet::Provisioner::Puppet"
              VagrantPlugins::VagrantHyperV::Provisioner::Puppet.new(env).provision_for_windows
            when "VagrantPlugins::Chef::Provisioner::ChefSolo"
              VagrantPlugins::VagrantHyperV::Provisioner::ChefSolo.new(env).provision_for_windows
            end
          else
            original_run_provisioner(env)
          end
        end
      end
    end
  end
end
