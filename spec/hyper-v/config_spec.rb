require "vagrant-hyperv/config"
require_relative "spec_helper"

describe VagrantPlugins::HyperV::Config do
  let(:instance) { VagrantPlugins::HyperV::Config.new }
  let(:machine) { Object.new }
  describe "Check host share config" do
    it "Should return the error messages under a key HyperV" do
      instance.host_config do |share|
        share.username = "vagrant"
      end
      error = instance.validate(machine)
      assert(true, error.has_key?("HyperV"))
    end
    it "Should raise errors for missing properties" do
      instance.host_config do |share|
        share.username = "vagrant"
      end
      error = instance.validate(machine)
      assert(true, !error["HyperV"].empty?)
    end
    it "Should have no errors when all properties are passed" do
      instance.host_config do |share|
        share.username = "vagrant"
        share.password = "my_secret_password"
      end
      error = instance.validate(machine)
      assert(true, error["HyperV"].empty?)
    end
  end
end
