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
        path << "/#{CGI::escape(options[:name])}"
      end
      path
    end

    def list(options={})
      ret = []
      res = @client.get("#{path(options)}", options)
      @client.logger.debug res.inspect
      parsed = @client.parse_response(res, true)
      @client.logger.debug parsed.inspect
      parsed.each do |q|
        @client.logger.debug "cache: " + q.inspect
        q = Cache.new(@client, q)
        ret << q
      end
      ret
    end

    # options:
    #  :name => can specify an alternative queue name
    def get(options={})
      if options.is_a?(String)
        options = {:name=>options}
      end
      options[:name] ||= @client.cache_name
      res = @client.parse_response(@client.get(path(options)))
      Cache.new(@client, res)
    end

    def clear(options={})
      res = @client.post(path(options) + "/clear")
      json = @client.parse_response(res, true)
      #return Message.new(self, res)
      return ResponseBase.new(json)
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
      q = @client.caches.get(:name=>name)
      @client.logger.debug "GOT Q: " + q.inspect
      @data = q.raw
      q
    end

    def reload
      load_cache
    end

    def size
      return raw["size"] if raw["size"]
      return @size if @size
      q = load_cache()
      @size = q.size
    end

    def put(k, v, options={})
      @client.items.put(k, v, options.merge(:cache_name=>name))
    end

    def get(k, options={})
      @client.items.get(k, options.merge(:cache_name=>name))
    end

    # Returns the url to this item. It does not actually get the item
    def url(k, options={})
      @client.items.url(k, options.merge(:cache_name=>name))
    end

    def delete(k, options={})
      @client.items.delete(k, options.merge(:cache_name=>name))
    end

    def increment(k, amount=1, options={})
      @client.items.increment(k, amount, options.merge(:cache_name=>name))
    end

    def clear(options={})
      @client.caches.clear(options.merge(:name=>name))
    end

  end

end

