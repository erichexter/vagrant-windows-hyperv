#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant Hyper-V plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.3.5"
  raise "The Vagrant Hyper-V plugin is only compatible with Vagrant 1.3+"
end

module VagrantPlugins
  module HyperV
    class Plugin < Vagrant.plugin("2")
      name "HyperV"
      description <<-DESC
      This plugin installs a provider that allows Vagrant to manage
      machines in Hyper-V.
      DESC

      config(:hyperv, :provider) do
        require_relative "config"
        Config
      end

      provider(:hyperv, parallel: true) do
        # Setup logging and i18n
        # setup_logging
        # setup_i18n

        # Return the provider
        require_relative "provider"
        Provider
      end

      # This initializes the internationalization strings.
      def self.setup_i18n

      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require "log4r"
        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_hyperv")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end