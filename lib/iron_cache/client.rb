require 'json'
require 'logger'
require 'rest'
require 'iron_core'

module IronCache

  class Client < IronCore::Client

    AWS_US_EAST_HOST = "cache-aws-us-east-1.iron.io"

    def self.version

    end

    attr_accessor :cache_name, :logger

    def initialize(options={})
      super("cache", options)

      @logger = IronCore::Logger

      @cache_name = options[:cache_name] || options['cache_name'] || "default"

      load_from_hash(:scheme => 'https',
                     :host => AWS_US_EAST_HOST,
                     :port => 443,
                     :api_version => 2,
                     :user_agent => 'iron_cache_ruby-' + IronCache::VERSION + ' (iron_core_ruby-' + IronCore.version + ')')

      if (not @token) || (not @project_id)
        IronCore::Logger.error 'IronWorkerNG', 'Both token and project_id must be specified'
        raise IronCore::IronError.new('Both token and project_id must be specified')
      end


    end

    def items
      return Items.new(self)
    end

    def cache

    end

    def caches
      return Caches.new(self)
    end


    def put(method, params={})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:body] = params.to_json

      IronCore::Logger.debug 'IronCore', "PUT #{url + method} with params='#{request_hash.to_s}'"

      @rest.put(url + method, request_hash)
    end


  end

  class Error < StandardError
    def initialize(msg, options={})
      super(msg)
      @options = options
    end

    def status
      @options[:status]
    end
  end


end

