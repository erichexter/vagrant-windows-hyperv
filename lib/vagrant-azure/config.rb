#--------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require 'vagrant'

module VagrantPlugins
  module WinAzure
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :storage_acct_name
      attr_accessor :storage_access_key
      attr_accessor :sb_namespace
      attr_accessor :sb_access_key
      attr_accessor :sb_issuer
      attr_accessor :mgmt_certificate
      attr_accessor :subscription_id
      attr_accessor :mgmt_endpoint
      attr_accessor :sql_auth_mode
      attr_accessor :sql_mgmt_endpoint

      attr_accessor :vm_name
      attr_accessor :vm_user
      attr_accessor :vm_password
      attr_accessor :vm_image
      attr_accessor :vm_location
      attr_accessor :vm_affinity_group

      attr_accessor :cloud_service_name
      attr_accessor :deployment_name
      attr_accessor :tcp_endpoints
      attr_accessor :ssh_private_key_file
      attr_accessor :ssh_certificate_file
      attr_accessor :ssh_port
      attr_accessor :vm_size
      attr_accessor :winrm_transport
      attr_accessor :availability_set_name
      attr_accessor :add_role

      def initialize
        @storage_access_key    = ENV["AZURE_STORAGE_ACCESS_KEY"]
        @storage_acct_name     = ENV["AZURE_STORAGE_ACCOUNT"]
        @sb_namespace          = ENV["AZURE_SERVICEBUS_NAMESPACE"]
        @sb_access_key         = ENV["AZURE_SERVICEBUS_ACCESS_KEY"]
        @sb_issuer             = ENV["AZURE_SERVICEBUS_ISSUER"]
        @mgmt_certificate      = ENV["AZURE_MANAGEMENT_CERTIFICATE"]
        @subscription_id       = ENV["AZURE_SUBSCRIPTION_ID"]
        @mgmt_endpoint         = ENV["AZURE_MANAGEMENT_ENDPOINT"]
        @sql_auth_mode         = ENV["AZURE_SQL_DATABASE_AUTHENTICATION_MODE"]
        @sql_mgmt_endpoint     = ENV["AZURE_SQL_DATABASE_MANAGEMENT_ENDPOINT"]
      end

      # def merge(other)
      #   puts "Merging properties..."

      #   @storage_acct_name = other.storage_acct_name || @storage_acct_name
      #   @storage_access_key = other.storage_access_key || @storage_access_key
      #   @sb_namespace = other.sb_namespace || @sb_namespace
      #   @sb_access_key = other.sb_access_key || @sb_access_key
      #   @sb_issuer = other.sb_issuer || @sb_issuer
      #   @mgmt_certificate = other.mgmt_certificate || @mgmt_certificate
      #   @subscription_id = other.subscription_id || @subscription_id
      #   @mgmt_endpoint = other.mgmt_endpoint || @mgmt_endpoint
      #   @sql_auth_mode = other.sql_auth_mode || @sql_auth_mode
      #   @sql_mgmt_endpoint = other.sql_mgmt_endpoint || @sql_mgmt_endpoint

      #   @vm_name = other.vm_name || @vm_name
      #   @vm_user = other.vm_user || @vm_user
      #   @vm_password = other.vm_password || @vm_password
      #   @vm_image = other.vm_image || @vm_image
      #   @vm_location = other.vm_location || @vm_location
      #   @vm_affinity_group = other.vm_affinity_group || @vm_affinity_group
      #   @cloud_service_name = other.cloud_service_name || @cloud_service_name
      #   @deployment_name = other.deployment_name || @deployment_name
      #   @tcp_endpoints = other.tcp_endpoints || @tcp_endpoints
      #   @ssh_private_key_file = other.ssh_private_key_file || @ssh_private_key_file
      #   @ssh_certificate_file = other.ssh_certificate_file || @ssh_certificate_file
      #   @ssh_port = other.ssh_port || @ssh_port
      #   @vm_size = other.vm_size || @vm_size
      #   @winrm_transport = other.winrm_transport || @winrm_transport
      #   @availability_set_name = other.availability_set_name || @availability_set_name
      #   @add_role = other.add_role || @add_role

      #   puts "Properties merged..."
      # end
    end
  end
end
