require 'cgi'

module IronCache
  class Caches

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def path(options={})
      path = "projects/#{@client.project_id}/caches"
      if options[:name]
        path << "/#{CGI::escape(options[:name]).gsub('+', '%20')}"
      end

      path
    end

    def list(options={})
      lst = call_api(:get, '', options)
      @client.logger.debug lst.inspect

      lst.map do |cache|
        @client.logger.debug "cache: " + cache.inspect
        Cache.new(@client, cache)
      end
    end

    # options:
    #  :name => can specify an alternative queue name
    def get(options={})
      opts = parse_opts(options)
      opts[:name] ||= @client.cache_name

      Cache.new(@client, call_api(:get, '', opts))
    end

    def clear(options={})
      ResponseBase.new(call_api(:post, '/clear', options))
    end

    def remove(options={})
      ResponseBase.new(call_api(:delete, '', options))
    end

    private

    def parse_opts(options={})
      options = options.is_a?(String) ? {:name => options} : options
    end

    def call_api(method, ext_path, options={})
      pth = path(parse_opts(options)) + ext_path
      res = @client.send(method, pth)

      @client.parse_response(res, true)
    end
  end

  class Cache

    def initialize(client, res)
      @client = client
      @data = res
    end

    def raw
      @data
    end

    def [](key)
      raw[key]
    end

    def id
      raw["id"]
    end

    def name
      raw["name"]
    end

    # Used if lazy loading
    def load_cache
      cache = @client.caches.get(:name => name)
      @client.logger.debug "GOT Q: " + cache.inspect

      @data = cache.raw
    end

    def reload
      load_cache
    end

    def size
      case
      when raw["size"]
        raw["size"]
      when @size
        @size
      else
        @size = load_cache.size
      end
    end

    def put(k, v, options={})
      @client.items.put(k, v, options.merge(:cache_name => name))
    end

    def get(k, options={})
      @client.items.get(k, options.merge(:cache_name => name))
    end

    # Returns the url to this item. It does not actually get the item
    def url(k, options={})
      @client.items.url(k, options.merge(:cache_name => name))
    end

    def delete(k, options={})
      @client.items.delete(k, options.merge(:cache_name => name))
    end

    def increment(k, amount=1, options={})
      @client.items.increment(k, amount, options.merge(:cache_name => name))
    end

    def clear(options={})
      @client.caches.clear(options.merge(:name => name))
    end

    def remove(options={})
      @client.caches.remove(options.merge(:name => name))
    end
  end

end

