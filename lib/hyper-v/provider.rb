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
require "log4r"
require "vagrant"

module VagrantPlugins
  module HyperV
    class Provider < Vagrant.plugin("2", :provider)

      def initialize(machine)
        @machine = machine
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def state
        # Run a custom action we define called "read_state" which does
        # what it says. It puts the state in the `:machine_state_id`
        # key in the environment.
        env = @machine.action("read_state")
        state_id = env[:machine_state_id]

        # Get the short and long description
        # TODO
        short = "Use the short description from WMI #{state_id}"
        long  = "Use the long description from WMI"

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "Hyper-V (#{id})"
      end

      def ssh_info
        # Run a custom action called "read_guest_ip" which does what it
        # says and puts the resulting SSH info into the `:machine_ssh_info`
        # key in the environment.
        env = @machine.action("read_guest_ip")
        if env[:machine_ssh_info]
          env[:machine_ssh_info].merge!(:port => 22)
        end
      end

      def driver
        @driver ||= Driver::Base.new()
      end
    end
  end
end
