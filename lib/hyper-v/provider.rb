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
        # If the VM is not created then we cannot possibly SSH into it, so
        # we return nil.
        return nil if state.id == :not_created

        # Return what we know. The host is always "127.0.0.1" because
        # VirtualBox VMs are always local. The port we try to discover
        # by reading the forwarded ports.

        # FIXME: Try to get the Host IP Through WMI Call.  Currently this is fed 
        # Internally
        return {
          :host => @machine.config.ssh.host,
          :port => @machine.config.ssh.guest_port
        }
      end
    end
  end
end
