require 'json'
require 'logger'
require 'rest'
require 'iron_core'

module IronCache

  class Client < IronCore::Client

    AWS_US_EAST_HOST = "cache-aws-us-east-1.iron.io"

    attr_accessor :logger

    def initialize(options={})
      default_options = {
        :scheme => 'https',
        :host => IronCache::Client::AWS_US_EAST_HOST,
        :port => 443,
        :api_version => 1,
        :user_agent => 'iron_mq_ruby-' + IronCache::VERSION + ' (iron_core_ruby-' + IronCore.version + ')',
        :cache_name => 'default'
      }

      super('iron', 'cache', options, default_options, [:project_id, :token, :api_version, :cache_name])

      IronCore::Logger.error 'IronCache', "Token is not set", IronCore::Error if @token.nil?

      check_id(@project_id, 'project_id')

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    def headers
      super.merge({'Authorization' => "OAuth #{@token}"})
    end

    def base_url
      super + @api_version.to_s + '/'
    end

    def items
      return Items.new(self)
    end

    def cache(name)
      return Cache.new(self, {"name"=>name})
    end

    def caches
      return Caches.new(self)
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

