#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "json"
require "vagrant/util/which"
require "vagrant/util/subprocess"

module VagrantPlugins
  module HyperV
    class Driver
      attr_reader :vmid

      # Regular Expression to parse the response from PowerShell Script
      ERROR_REGEXP  = /===Begin-Error===(.+?)===End-Error===/m
      OUTPUT_REGEXP = /===Begin-Output===(.+?)===End-Output===/m

      def initialize(machine)
        @vmid = machine.id
        @output = nil
        @machine = machine
      end

      def execute(path, options, &block)
        r = execute_powershell(path, options, &block)
        output = r.stdout.gsub("\r\n", "\n")
        error = r.stdout.gsub("\r\n", "\n")

        if r.exit_code != 0
          raise Errors::PowerShellError,
            path: path,
            stderr: r.stderr
        end

        error_response = ERROR_REGEXP.match(error)
        success_response = OUTPUT_REGEXP.match(output)

        if error_response
          result = JSON.parse(error_response[1])
          message = result["message"]
          type = result["type"]
          if  type == "PowerShellError"
            raise Errors::PowerShellError,
              path: path, stderr: message
          elsif type == "NetShareError"
            raise Errors::NetShareError,
              stderr: message
          end
        end
        return nil if !success_response
        return JSON.parse(success_response[1])
      end

      def ssh_info
        @ssh_info ||= @machine.ssh_info
      end

      def remote_credentials
        @remote_credentials ||= {  guest_ip: ssh_info[:host],
           username:  ssh_info[:username],
           password: "vagrant" }
      end

      def run_remote_ps(command, &block)
        options = remote_credentials.merge(command: command)
        execute('run_in_remote.ps1', options, &block)
      end

      def export_vm_to(path)
        options = {
           vm_id: vmid,
           path: windows_path(path)
         }
        execute("export_vm.ps1", options)
      end

      def share_folders(hostpath, share_name)
        options = {
          path: hostpath,   # Use Unix path format
          share_name: safe_share_name(share_name),
          host_share_username: @machine.provider_config.host_share.username
        }
        execute('set_smb_share.ps1', options)
      end

      def start
        execute('hyperv_manager.ps1', { vm_id: vmid, command: "start" })
      end

      def stop
        execute('hyperv_manager.ps1', { vm_id: vmid, command: "stop" })
      end

      def suspend
        execute('hyperv_manager.ps1', { vm_id: vmid, command: "suspend" })
      end

      def get_current_state
        execute('hyperv_manager.ps1', { vm_id: vmid, command: "status" })
      end

      def resume
        execute('hyperv_manager.ps1', { vm_id: vmid, command: "resume" })
      end

      def read_guest_ip
        execute('get_network_config.ps1', { vm_id: vmid })
      end

      def upload(from, to)
        options = {
          vm_id: vmid,
          host_path: windows_path(from),
          guest_path: windows_path(to)
        }.merge(remote_credentials)
        execute('upload_file.ps1',options)
      end

      protected

      def windows_path(path)
        if path
          path = path.gsub("/","\\")
          path = "c:#{path}" if path =~ /^\\/
        end
        path
      end

      def safe_share_name(name)
        if name
          new_path = name.strip.gsub(' ', '_').sub(/^_/, '')
        else
         raise "Errors::InvalidShareName"
        end
      end


      def execute_powershell(path, options, &block)
        lib_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        path = lib_path.join(path).to_s.gsub("/", "\\")
        options = options || {}
        ps_options = []
        options.each do |key, value|
          ps_options << "-#{key}"
          ps_options << "'#{value}'"
        end

        command = ["powershell", "-NoProfile", "-ExecutionPolicy",
            "Bypass", path, ps_options, {notify: [:stdout, :stderr, :stdin]}].flatten

        Vagrant::Util::Subprocess.execute(*command, &block)
      end
    end
  end
end
