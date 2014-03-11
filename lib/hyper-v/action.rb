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
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use action_halt
            b2.use action_start
          end
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use StopInstance
            b2.use Call, WaitForState, :off, 120 do |env1, b3|
              if env1[:result]
                env[:ui].info I18n.t("vagrant_hyperv.message_turned_off")
              end
            end
          end
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use SuspendInstance
          end
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use StartInstance
          b.use Call, WaitForState, :running, 10 do |env, b1|
            if env[:result]
              b1.use WaitForBootReady
              b1.use Provision
              b1.use ShareFolders
              b1.use SyncFolders
            else
              env[:ui].info I18n.t("vagrant_hyperv.errors.machine_boot_error")
            end
          end
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :paused do |env, b2|
            if !env[:result]
              b2.use Message, "Machine not suspended"
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
          b.use Call, IsState, :not_created do |env1, b1|
            if env1[:result]
              b1.use Import
              b1.use action_start
            else
              b1.use Call, IsState, :off do |env2, b2|
                if env2[:result]
                  b2.use action_start
                else
                  b2.use Message, "Machine already created"
                end
              end
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
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use Call, IsState, :running do |env1, b3|
              if !env1[:result]
                b3.use Message, "Machine is not running, Please turn it on."
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
          b.use Call, IsState, :not_created do |env1, b2|
            if env1[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use SetupPackageFiles
            b2.use action_halt
            b2.use Call, WaitForState, :off, 120 do |env2, b3|
              if env2[:result]
                b3.use Export
                b3.use Package
              else
                env2[:ui].info("Machine did not reload, Check machine's status")
              end
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end
            b2.use Call, IsState, :running do |env2, b3|
              if !env2[:result]
                b3.use MessageNotRunning
              else
                b3.use Provision
                b3.use SyncFolders
              end
            end
          end
        end
      end

      def self.action_rdp
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end

            b2.use Call, IsState, :running do |env1, b3|
              if !env1[:result]
                b3.use Message, I18n.t("vagrant_hyperv.message_rdp_not_ready")
                next
              end

              b3.use Rdp
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :IsState, action_root.join("is_state")
      autoload :Message, action_root.join("message")
      autoload :ReadState, action_root.join("read_state")
      autoload :Import, action_root.join("import")

      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :ResumeInstance, action_root.join('resume_instance')
      autoload :SuspendInstance, action_root.join('suspend_instance')
      autoload :SyncFolders, action_root.join('sync_folders')

      autoload :WaitForState, action_root.join('wait_for_state')
      autoload :ReadGuestIP, action_root.join('read_guest_ip')

      autoload :ShareFolders, action_root.join('share_folders')
      autoload :SSHExec, action_root.join('ssh_exec')
      autoload :SetupPackageFiles, action_root.join("setup_package_files")

      autoload :Export, action_root.join("export")
      autoload :Package, action_root.join("package")
      autoload :Provision, action_root.join('provision')
      autoload :Rdp, action_root.join("rdp")
      autoload :WaitForBootReady, action_root.join("wait_for_boot_ready")
    end
  end
end
