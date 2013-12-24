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

require "pathname"
require "vagrant/action/builder"

module VagrantPlugins
  module HyperV
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          # b.use SyncFolders
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use ConnectHyperv
            b2.use StopInstance
          end
        end
      end

      def self.action_start
        #TODO: Check for instance already running.
        Vagrant::Action::Builder.new.tap do |b|
          b.use action_boot
        end
      end

      def self.action_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use StartInstance
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBoxUrl
          b.use ConfigValidate
          b.use ConnectHyperv
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_prepare_boot
                  b2.use StartInstance
                else
                  b2.use MessageAlreadyCreated
                end
              end
            else
              b1.use action_prepare_boot
              b1.use Import
              b1.use action_start
            end
          end
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHyperv
          b.use ReadState
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use SSHExec
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :ConnectHyperv, action_root.join("connect_hyperv")
      autoload :ReadState, action_root.join("read_state")
      autoload :Import, action_root.join("import")
      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :ForwardPorts, action_root.join('forward_ports')
      autoload :SyncFolders, action_root.join('sync_folders')
    end
  end
end
