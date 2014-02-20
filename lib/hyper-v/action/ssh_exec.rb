#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "log4r"
module VagrantPlugins
  module HyperV
    module Action
      class SSHExec  < Vagrant::Action::Builtin::SSHExec
        def initialize(app, env)
          @app  = app
        end

        def call(env)
          if env[:machine].config.vm.guest != :windows
            env[:ui].info "SSH is not supported for this VM. use vagrant rdp"
          else
            super
          end
          @app.call(env)
        end
      end
    end
  end
end
