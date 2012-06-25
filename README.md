IronCache Ruby Client
-------------

Getting Started
==============

Install the gem:

    gem install iron_cache

Setup your Iron.io credentials: http://dev.iron.io/articles/configuration/

Create an IronCache client object:

    @iron_cache = IronCache::Client.new


The Basics
=========

**Put** an item in the cache:

    msg = @iron_cache.items.put("mykey", "hello world!")
    p msg

**Get** an item from the cache:

    msg = @iron_cache.items.get("mykey")
    p msg

**Delete** an item from the cache:

    res = msg.delete # or @iron_cache.items.delete("mykey")
    p res

**Increment** an item from the cache:
    msg = @iron_cache.items.increment("mykey", amount=1)
    p res

Cache Selection
===============

One of the following:

1. Pass `:cache_name=>'my_cache'` into IronCache::Client.new
1. `@iron_cache.cache_name = 'my_cache'`
1. Pass `:cache_name=>'my_cache'` into any post(), get(), or delete()

Cache Information
=================

    cache = @iron_cache.queues.get(:name=>"my_cache")
    puts "size: #{cache.size}"

 