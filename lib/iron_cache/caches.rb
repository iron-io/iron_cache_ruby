module IronCache
  class Caches

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def path(options={})
      path = "projects/#{@client.project_id}/caches"
    end

    def list(options={})
      ret = []
      res, status = @client.get("#{path(options)}", options)
      res.each do |q|
        #p q
        q = Cache.new(self, q)
        ret << q
      end
      ret
    end

    # options:
    #  :name => can specify an alternative queue name
    def get(options={})
      res, status = @client.get("#{path(options)}/#{options[:name]}")
      return Cache.new(self, res)
    end


  end

  class Cache

    def initialize(queues, res)
      @queues = queues
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

    def size
      return raw["size"] if raw["size"]
      return @size if @size
      q = @queues.get(:name=>name)
      @size = q.size
      @size
    end

    def total_messages
      return raw["total_messages"] if raw["total_messages"]
      return @total_messages if @total_messages
      q = @queues.get(:name=>name)
      @total_messages = q.total_messages
      @total_messages
    end

    # def delete
    # @messages.delete(self.id)
    # end
  end

end

