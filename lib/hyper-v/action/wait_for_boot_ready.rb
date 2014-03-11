#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "log4r"
require "timeout"

module VagrantPlugins
  module HyperV
    module Action
      # This action checks if the Virtual Machine's boot sequence is complete
      # and the machine returns back its IP Address.
      class WaitForBootReady
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
        end

        def call(env)
          env[:ui].info "Waiting for the VM to Boot... [default timeout 120 sec]"
          guest_ip = env[:machine].action("read_guest_ip")[:ssh_info]
          raise Errors::IPTimeOut if guest_ip.nil? || guest_ip[:host].nil?
          @app.call(env)
        end
      end
    end
  end
end
