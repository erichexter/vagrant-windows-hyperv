#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "minitest/autorun"
require 'mocha/setup'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
