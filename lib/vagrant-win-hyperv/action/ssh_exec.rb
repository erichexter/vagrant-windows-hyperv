#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class SSHExec  < Vagrant::Action::Builtin::SSHExec
        def initialize(app, env)
          super
        end

        def call(env)
          if env[:machine].provider_config.guest == :windows
            raise Errors::SSHNotAvailable,
              guest: env[:machine].provider_config.guest
          else
            super
          end
          @app.call(env)
        end
      end
    end
  end
end
