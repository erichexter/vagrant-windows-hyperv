#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "pathname"
require "vagrant/action/builder"

module VagrantPlugins
  module VagrantHyperV
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

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
                b3.use Message, I18n.t("vagrant_hyperv.message_not_running")
              else
                b3.use Provision
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

      autoload :SyncedFolders, action_root.join('synced_folders')
      # autoload :WaitForState, action_root.join('wait_for_state')
      autoload :SSHExec, action_root.join('ssh_exec')
      autoload :Export, action_root.join("export")
      autoload :Package, action_root.join("package")
      autoload :Provision, action_root.join('provision')
      autoload :Rdp, action_root.join("rdp")
    end
  end
end
