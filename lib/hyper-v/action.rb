#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "pathname"
require "vagrant/action/builder"

module VagrantPlugins
  module HyperV
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use action_halt
            b2.use Call, WaitForState, :off, 120 do |env2, b3|
              if env2[:result]
                b3.use action_up
              else
                env2[:ui].info("Machine did not reload, Check machine's status")
              end
            end
          end
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
            b2.use StopInstance
          end
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use SuspendInstance
          end
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use StartInstance
          b.use ShareFolders
          b.use Provision
          b.use SyncFolders
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsSuspended do |env, b2|
            if !env[:result]
              b2.use MessageNotSuspended
              next
            end
            b2.use ResumeInstance
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBoxUrl
          b.use ConfigValidate
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_start
                else
                  b2.use MessageAlreadyCreated
                end
              end
            else
              b1.use Import
              b1.use action_start
            end
          end
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
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
            b2.use Call, IsRunning do |env1, b3|
              if !env1[:result]
                b3.use MessageNotRunning
              else
                b3.use SSHExec
              end
            end
          end
        end
      end

      def self.action_read_guest_ip
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadGuestIP
        end
      end

      def self.action_package
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsCreated do |env1, b2|
            if !env1[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use SetupPackageFiles
            b2.use action_halt
            b2.use Call, WaitForState, :off, 120 do |env2, b3|
              b3.use Export
              b3.use Package
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use Call, IsRunning do |env2, b3|
              if !env2[:result]
                b3.use MessageNotRunning
              else
                b3.use Provision
              end
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :IsRunning, action_root.join("is_running")
      autoload :IsSuspended, action_root.join("is_suspended")
      autoload :ReadState, action_root.join("read_state")
      autoload :Import, action_root.join("import")
      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :ResumeInstance, action_root.join('resume_instance')
      autoload :SuspendInstance, action_root.join('suspend_instance')
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :MessageNotRunning, action_root.join('message_not_running')
      autoload :MessageNotSuspended, action_root.join('message_not_suspended')
      autoload :SyncFolders, action_root.join('sync_folders')
      autoload :WaitForState, action_root.join('wait_for_state')
      autoload :ReadGuestIP, action_root.join('read_guest_ip')
      autoload :ShareFolders, action_root.join('share_folders')
      autoload :SSHExec, action_root.join('ssh_exec')
      autoload :SetupPackageFiles, action_root.join("setup_package_files")
      autoload :Export, action_root.join("export")
      autoload :Package, action_root.join("package")
      autoload :Provision, action_root.join('provision')
    end
  end
end
