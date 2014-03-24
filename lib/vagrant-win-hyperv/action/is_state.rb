#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class IsState
        def initialize(app, env, state)
          @app = app
          @state = state
        end

        def call(env)
          env[:result] = env[:machine].state.id == @state
          @app.call(env)
        end
      end
    end
  end
end
