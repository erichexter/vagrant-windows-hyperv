#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
module VagrantPlugins
  module HyperV
    module Action
      class Provision < Vagrant::Action::Builtin::Provision
        # Override this method from core vagrant, here we branch out the provision for windows
        def run_provisioner(env, name, p)
          env[:ui].info("provisioner for #{name}")
          if env[:machine].provider_config.guest == :windows
            case p.class.to_s
            when "VagrantPlugins::Shell::Provisioner"
              Provisioner::Shell.new(env,p).provision_for_windows
            end
          else
            p.provision
          end
        end
      end
    end
  end
end
