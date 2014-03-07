#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "json"
require "vagrant/util/which"
require "vagrant/util/subprocess"

module VagrantPlugins
  module HyperV
    class Driver
      attr_reader :vmid

      def initialize(machine)
        @vmid = machine.id
        check_power_shell
        @output = nil
        @machine = machine
      end

      def execute(path, options, &block)
        if block_given?
          r = execute_powershell(path, options, &block)
        else
          r = execute_powershell(path, options) do |type, data|
            process_output(type, data)
          end
          if success?
            JSON.parse(json_output[:success].join) unless json_output[:success].empty?
          else
            message = json_output[:error].join unless json_output[:error].empty?
            raise Error::SubprocessError, message if message
          end
        end
      end

      def raw_execute(command)
        command = [command , {notify: [:stdout, :stderr, :stdin]}].flatten
        clear_output_buffer
        Vagrant::Util::Subprocess.execute(*command) do |type, data|
          process_output(type, data)
        end
      end

      def export_vm_to(path)
        options = {
           vm_id: vmid,
           path: windows_path(path)
         }
        execute("export_vm.ps1", options)
      end

      def read_guest_ip
        execute('get_network_config.ps1', { vm_id: vmid })
      end

      def get_current_state
        execute('get_vm_status.ps1', { vm_id: vmid })
      end

      def resume
        execute('resume_vm.ps1', { vm_id: vmid })
      end

      def share_folders(hostpath, share_name)
        options = {
          path: hostpath,   # Use Unix path format
          share_name: safe_share_name(share_name),
          host_share_username: @machine.provider_config.host_share.username
        }
        execute('set_smb_share.ps1', options)
      end

      def mount_to_windows(from, to, ssh_info)
        options = {
                    hostpath: windows_path(from),
                    guest_ip: ssh_info[:host],
                    guest_path: windows_path(to),
                    username: ssh_info[:username],
                    password: "vagrant"
                  }
        execute('mount_share.ps1', options)
      end

      def start
        execute('start_vm.ps1', { vm_id: vmid })
      end

      def stop
        execute('stop_vm.ps1', { vm_id: vmid })
      end

      def suspend
        execute('suspend_vm.ps1', { vm_id: vmid })
      end

      def upload(from, to)
        options = {
          vm_id: vmid,
          host_path: windows_path(from),
          guest_path: windows_path(to)
        }
        execute('upload_file.ps1',options)
      end

      def folder_copy(from, to, ssh_info)
        options = {
          vm_id: vmid,
          username: ssh_info[:username],
          host_path: windows_path(from),
          guest_path: windows_path(to),
          guest_ip: ssh_info[:host],
          password: "vagrant"
        }
        execute('file_sync.ps1', options)
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

      def json_output
        return @json_output if @json_output
        json_success_begin = false
        json_error_begin = false
        success = []
        error = []
        @output.split("\n").each do |line|
          json_error_begin = false if line.include?("===End-Error===")
          json_success_begin = false if line.include?("===End-Output===")
          message = ""
          if json_error_begin || json_success_begin
            message = line.gsub("\\'","\"")
          end
          success << message if json_success_begin
          error << message if json_error_begin
          json_success_begin = true if line.include?("===Begin-Output===")
          json_error_begin = true if line.include?("===Begin-Error===")
        end
        @json_output = { :success => success, :error => error }
      end

      def success?
        @error_messages.empty? && json_output[:error].empty?
      end

      def process_output(type, data)
        if type == :stdout
          @output = data.gsub("\r\n", "\n")
        end
        if type == :stdin
          # $stdin.gets.chomp || ""
        end
        if type == :stderr
          @error_messages = data.gsub("\r\n", "\n")
        end
      end

      def clear_output_buffer
        @output = ""
        @error_messages = ""
        @json_output = nil
      end

      def check_power_shell
        unless Vagrant::Util::Which.which('powershell')
          raise "Power Shell not found"
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
        clear_output_buffer
        command = ["powershell", "-NoProfile", "-ExecutionPolicy",
            "Bypass", path, ps_options, {notify: [:stdout, :stderr, :stdin]}].flatten

        Vagrant::Util::Subprocess.execute(*command, &block)
      end
    end
  end
end
