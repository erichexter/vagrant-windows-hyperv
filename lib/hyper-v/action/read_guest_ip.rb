#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "log4r"
require "timeout"

module VagrantPlugins
  module HyperV
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadGuestIP
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
        end

        def call(env)
          env[:machine_ssh_info] = read_host_ip(env)
          @app.call(env)
        end

        def read_host_ip(env)
          return nil if env[:machine].id.nil?
          # Get Network details from WMI Provider
          # Wait for 120 sec By then the machine should be ready
          guest_ip = nil
          begin
            Timeout.timeout(120) do
            begin
              network_info  = env[:machine].provider.driver.read_guest_ip
              guest_ip = network_info["ip"]
              if !guest_ip.empty? && (/\d+(\.)\d+(\.)\d+(\.)\d+/.match(guest_ip).nil?)
                guest_ip = ""
              end
              sleep 10 if guest_ip.empty?
              end while guest_ip.empty?
            end
          rescue Timeout::Error
            @logger.info("Cannot find the IP address of the virtual machine")
          end
          return { host: guest_ip } unless guest_ip.empty?
        end
      end
    end
  end
end
