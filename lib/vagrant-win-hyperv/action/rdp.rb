#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"
require "pathname"
require "vagrant/util/powershell"

module VagrantPlugins
  module VagrantHyperV
    module Action
      # This action generates a .rdp file into the root path of the project.
      # and establishes a RDP session with necessary resource sharing
      class Rdp
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::rdp")
        end

        def call(env)
          if env[:machine].config.vm.guest != :windows
            raise Errors::RDPNotAvailable,
              guest: env[:machine].config.vm.guest
          end
          @env = env
          @env[:ui].detail I18n.t("vagrant_win_hyperv.generating_rdp")
          generate_rdp_file
          command = ["mstsc", "machine.rdp"]
          Vagrant::Util::PowerShell.execute(*command)
        end

        def generate_rdp_file
          ssh_info = @env[:machine].ssh_info
          rdp_options = {
            "username:s" => ssh_info[:username],
            "prompt for credentials:i" => "1",
            "full address:s" => ssh_info[:host]
          }
          file = File.open("machine.rdp", "w")
            rdp_options.each do |key, value|
              file.puts "#{key}:#{value}"
          end
          file.close
        end
      end
    end
  end
end
