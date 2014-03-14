#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module HyperV
    module Action
      class Message
        def initialize(app, env, message)
          @app = app
          @message = message
        end

        def call(env)
          env[:ui].info @message
          @app.call(env)
        end
      end
    end
  end
end
