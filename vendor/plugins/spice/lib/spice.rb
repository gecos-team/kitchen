require 'rest-client'
require 'mixlib/authentication'
require 'yajl'
require 'cgi'

require 'spice/authentication'
require 'spice/chef'

require 'spice/core_ext/hash'

require 'spice/role'
require 'spice/client'
require 'spice/cookbook'
require 'spice/data_bag'
require 'spice/node'
require 'spice/environment'
require 'spice/search'
require 'spice/connection'

require 'spice/version'
require 'spice/mock'

module Spice

  class << self
    attr_writer :server_url, :client_name, :connection, :host, :port, :scheme,
                :key_file, :raw_key, :chef_version, :url_path

    def default_server_url
      @default_server_url ||= "http://localhost:4000"
    end

    def default_url_path
      @default_url_path ||= ""
    end

    def default_host
      @default_host ||= "localhost"
    end

    def default_port
      @default_port ||= "4000"
    end

    def default_scheme
      @default_scheme ||= "http"
    end

    def server_url
      @server_url || default_server_url
    end

    def url_path
      @url_path || default_url_path
    end

    def host
      @host || default_host
    end

    def port
      @port || default_port
    end

    def scheme
      @scheme || default_scheme
    end

    def client_name
      @client_name
    end

    def key_file
      @key_file
    end

    def raw_key
      @raw_key
    end

    def key_file=(new_key_file)
      raw_key = File.read(new_key_file)
      assert_valid_key_format!(raw_key)
      @key_file = new_key_file
      @raw_key = raw_key
    end

    def default_chef_version
      @default_chef_version ||= "0.10.4"
    end

    def chef_version
      @chef_version || default_chef_version
    end

    def connection
      @connection
    end

    def connect!
      # allow old-style connection setup
      if host != default_host || port != default_port || scheme != default_scheme || url_path != default_url_path
        url = "#{scheme}://#{host}:#{port}#{url_path}"
      else
        url = server_url
      end
      @connection = Connection.new(
        :server_url => url,
        :client_name => client_name,
        :key_file => key_file
      )
    end

    def reset!
      @server_url = default_server_url
      @host = default_host
      @port = default_port
      @scheme = default_scheme
      @chef_version = default_chef_version
      @key_file = nil
      @client_name = nil
      @connection = nil
    end

    def setup
      if block_given?
        yield self
      end
      connect!
    end

    def mock
      Spice::Mock.setup_mock_client
    end

    # def autoconfigure!(path=nil)
    #   path ||= "~/.chef/"
    #   knife = File.exist?("~/.chef/knife.rb") && File.expand_path(path + "~/.chef/knife.rb")
    #   client = File.exist?("/etc/chef/client.rb") && File.expand_path("/etc/chef/client.rb")
    #
    #   if knife
    #     raw_config = IO.read(knife)
    #   elsif
    #     raw_config = IO.read(client)
    #   end
    #
    #   @values = {}
    #   raw_config.each_line do |line|
    #     if line =~ /^chef_server_url.*/
    #       @values[:chef_server_url] = parse_line(line)
    #     elsif line =~ /^node_name.*/
    #       @values[:node_name] = parse_line(line)
    #     elsif line =~ /^client_key.*/
    #       @values[:client_key] = parse_line(line)
    #     end
    #   end
    # end

    private

    def assert_valid_key_format!(raw_key)
      unless (raw_key =~ /\A-----BEGIN RSA PRIVATE KEY-----$/) &&
         (raw_key =~ /^-----END RSA PRIVATE KEY-----\Z/)
        msg = "The file #{key_file} does not contain a correctly formatted private key.\n"
        msg << "The key file should begin with '-----BEGIN RSA PRIVATE KEY-----' and end with '-----END RSA PRIVATE KEY-----'"
        raise ArgumentError, msg
      end
    end

    def parse_line(line)
      line.strip.split.last.gsub("'", "")
    end
  end
end
