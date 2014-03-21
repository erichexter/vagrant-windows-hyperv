#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-win-hyperv/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-win-hyperv"
  spec.version       = VagrantPlugins::HyperV::VERSION
  spec.authors       = ["Ramakrishnan"]
  spec.email         = ["ramakrishnan.v@happiestminds.com"]
  spec.description   = "Enable Vagrant to manage Virtual Machine created using Hyper-V"
  spec.summary       = "Enable Vagrant to manage Virtual Machine created using Hyper-V"
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "json"
end
