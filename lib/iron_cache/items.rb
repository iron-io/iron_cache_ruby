require 'cgi'

module IronCache
  class Items

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def path(key, options={})
      path = "projects/#{@client.project_id}/caches/#{CGI::escape(options[:cache_name] || @client.cache_name)}/items/#{CGI::escape(key)}#{'/increment' if options[:increment] == true}"
    end

    # options:
    #  :queue_name => can specify an alternative queue name
    #  :timeout => amount of time before message goes back on the queue
    def get(key, options={})
      begin
        res = @client.get(path(key, options), options)
        @client.logger.debug "GET response: " + res.inspect
        json = @client.parse_response(res, true)
        return Item.new(self, json)
      rescue Rest::HttpError => ex
        @client.logger.debug ex.inspect
        if ex.code == 404
          return nil
        end
        raise ex
      end
    end

    def url(key, options={})
      @client.url(path(key, options))
    end

    # options:
    #  :cache_name => can specify an alternative queue name
    #  :expires_in => After this delay in seconds, message will be automatically removed from the cache.
    def put(key, value, options={})
      to_send = options
      to_send[:value] = value
      res = @client.put(path(key, options), to_send)
      json = @client.parse_response(res, true)
      #return Message.new(self, res)
      return ResponseBase.new(json)
    end
    
    # options:
    #  :cache_name => can specify an alternative queue name    
    def increment(key, amount=1, options={})
      options = options.merge(:increment => true)
      res = @client.post(path(key, options), {:amount => amount})
      hash = @client.parse_response(res, true)
      @client.logger.debug "increment response: " + hash.inspect
      hash["key"] ||= key
      return Item.new(self, hash)
    end

    def delete(key, options={})
      path2 = "#{self.path(key, options)}"
      res = @client.delete(path2)
      json = @client.parse_response(res, true)
      #return Message.new(self, res)
      return ResponseBase.new(json)
    end

  end

  class ResponseBase
    def initialize(res)
      @data = res
    end

    def raw
      @data
    end

    def [](key)
      raw[key]
    end

    #def id
    #  raw["id"]
    #end

    def msg
      raw["msg"]
    end

  end

  class Item < ResponseBase

    def initialize(messages, res)
      super(res)
      @messages = messages
    end

    def key
      raw["key"]
    end

    def value
      raw["value"]
    end

    def delete
      @messages.delete(self.key, :cache_name => raw['cache'])
    end
  end

end
