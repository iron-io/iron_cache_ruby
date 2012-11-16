IronCache Ruby Client
-------------

Getting Started
==============

1\. Install the gem:

    gem install iron_cache

2\. Setup your Iron.io credentials: http://dev.iron.io/articles/configuration/

3\. Create an IronCache client object:

    @client = IronCache::Client.new

The Basics
=========

**Get a Cache object**

You can have as many caches as you want, each with their own unique set of items.

    @cache = @client.cache("my_cache")

Now you can use it:

**Put** an item in the cache:

    @cache.put("mykey", "hello world!")

**Get** an item from the cache:

    item = @cache.get("mykey")
    p item.value

**Delete** an item from the cache:

    res = msg.delete # or @cache.delete("mykey")
    p res

**Increment** an item in the cache:

    msg = @cache.increment("mycounter", 1)
    p res

For all the options for each of these methods, please see our [API docs](http://dev.iron.io/cache/reference/api/). Every option can be passed in
via an optional hash in the above methods, eg:

    @cache.put("mykey", "hello world!", :expires_in=>3600)


Cache Information
=================

    cache = @iron_cache.cache("my_cache")
    puts "name: #{cache.name}"

Using As Rails Store
====================

You can use IronCache as any other rails store. Put iron.json into your project's config dir, add iron_cache to Gemfile and you are ready to go.

    config.cache_store = :iron_cache_store

Alternatively, you can supply project_id and token in code.

    config.cache_store = :iron_cache_store, :project_id => 'XXX', :token => 'YYY'


Using As Rails Session Store
====================

You can use IronCache as any other rails session store. Put iron.json into your project's config dir, add iron_cache to Gemfile and you are ready to go.

`config/initializers/session_store.rb` :

```ruby
AppName::Application.config.session_store :iron_cache_store
```

Alternatively, you can supply project_id and token in code.

```ruby
AppName::Application.config.session_store :iron_cache,
                                          project_id: 'XXX',
                                          token: 'YYY',
                                          namespace: 'other-cache-name',
                                          expires_in: 7200
```