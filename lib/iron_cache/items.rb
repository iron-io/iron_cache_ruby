module IronCache
  class Items

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def path(key, options={})
      path = "/projects/#{@client.project_id}/caches/#{options[:cache_name] || @client.cache_name}/objects/#{key}"
    end

    # options:
    #  :queue_name => can specify an alternative queue name
    #  :timeout => amount of time before message goes back on the queue
    def get(key, options={})
      begin
        res, status = @client.get(path(key, options), options)
        @client.logger.debug "GET response: " + res.inspect
        return Item.new(self, res)
      rescue IronCache::Error => ex
        if ex.status == 404
          return nil
        end
        raise ex
      end

    end

    # options:
    #  :cache_name => can specify an alternative queue name
    #  :expires_in => After this delay in seconds, message will be automatically removed from the cache.
    def put(key, value, options={})
      to_send = {}
      to_send[:body] = value
      res, status = @client.put(path(key, options), to_send)
      #return Message.new(self, res)
      return ResponseBase.new(res)
    end

    def delete(key, options={})
      path2 = "#{self.path(key, options)}"
      res, status = @client.delete(path2)
      res
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

    def id
      raw["id"]
    end

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
      @messages.delete(self.id)
    end
  end

end
