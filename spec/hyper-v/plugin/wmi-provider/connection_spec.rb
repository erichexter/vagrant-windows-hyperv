=begin
require "minitest/autorun"
require 'mocha/setup'
require "hyper-v/plugin/wmi-provider"

module VagrantPlugins
  module HyperV
    describe WMIProvider::Connection do
      describe '#new' do
        it 'should take a path for connection and return a WIN32OLE object' do
          WIN32OLE.stubs(:connect).returns(Object.new)
          wmi_provider = WMIProvider::Connection.new('some_path')
          assert wmi_provider.must_be_instance_of(WMIProvider::Connection)
        end

        describe 'For an instance of connection' do
          before do
            WIN32OLE.stubs(:connect).returns(Object.new)
            @wmi_provider = WMIProvider::Connection.new('some_path')
          end
          it 'Should respond to attribute reader for connection' do
            assert @wmi_provider.must_respond_to(:connection)
          end

          it 'Should find a VM by name' do
            #@wmi_provider.connection.stubs(:EachQuery).returns([])
            @wmi_provider.connection.stubds(:execute).returns(WMIProvider::Machine.new('machine'))
            assert @wmi_provider.find_vm_by_id('an_unique_id').must_be_instance_of(WMIProvider::Machine)
          end
        end

      end
    end
  end
end
=end
