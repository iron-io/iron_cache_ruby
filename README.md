IronCache Ruby Client
-------------

Getting Started
==============

1. Install the gem:

    gem install iron_cache

2. Setup your Iron.io credentials: http://dev.iron.io/articles/configuration/

3. Create an IronCache client object:

    @client = IronCache::Client.new

The Basics
=========

**Get a cache object**

You can have as many caches as you want, each with their own unique set of items.

    @cache = @client.cache("my_cache")

Now you can use it:

**Put** an item in the cache:

    msg = @cache.put("mykey", "hello world!")
    p msg

**Get** an item from the cache:

    msg = @cache.get("mykey")
    p msg

**Delete** an item from the cache:

    res = msg.delete # or @cache.delete("mykey")
    p res

**Increment** an item in the cache:

    msg = @cache.increment("mycounter", 1)
    p res

Cache Information
=================

    cache = @iron_cache.cache("my_cache")
    puts "name: #{cache.name}"

