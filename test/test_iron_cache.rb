gem 'test-unit'
require 'test/unit'
require 'yaml'
require_relative 'test_base'

class IronCacheTests < TestBase
  def setup
    super
  end

  def test_basics
    @client.cache_name = 'test_basics'
    clear_queue

    k = "key1"
    v = "hello world!"
    res = @client.items.put(k, v)
    # another naming option we could try:
    #res = @client.cache('test_basics').items.put("key1", "hello world!")
    p res
    assert res.msg

    res = @client.items.get(k)
    p res
    assert res["key"]
    assert res.key
    assert_equal k, res.key
    assert_equal v, res.value

    res = @client.items.delete(res.key)
    p res
    puts "shouldn't be any more"
    res = @client.items.get(k)
    p res
    assert_nil res

    # new style of referencing cache
    cache = @client.cache("test_basics")
    res = cache.put(k, v)
    p res
    assert res.msg

    res = cache.get(k)
    p res
    assert res["key"]
    assert res.key
    assert_equal k, res.key
    assert_equal v, res.value

    res = cache.delete(k)
    p res
    puts "shouldn't be any more"
    res = cache.get(k)
    p res
    assert_nil res

    # test delete by item
    res = cache.put(k, v)
    p res
    assert res.msg

    res = cache.get(k)
    p res
    assert res.value
    res = res.delete
    p res
    puts "shouldn't be any more"
    res = cache.get(k)
    p res
    assert_nil res


    # different cache names
    c = @client.cache("new_style")
    c.put(k, v)
    item = c.get(k)
    assert_equal v, item.value
    item.delete
    item = c.get(k)
    assert_nil item


  end

  def test_caches
    caches = @client.caches.list
    p caches
    assert caches
    assert caches.is_a?(Array)
    assert caches.size > 0
    assert caches[0].name
    #assert caches[0].size

    cache = @client.caches.get(caches[0].name)
    p cache
    assert cache.name
    #assert cache.size

    cache = @client.cache(caches[0])
    p cache
    assert cache.name
    #assert cache.size

  end

  def test_expiry
    @client.cache_name = 'test_basics'
    clear_queue
    k = "key1"
    v = "hello world!"
    res = @client.items.put(k, v, :expires_in => 10)

    res = @client.items.get(k)
    p res
    assert_equal k, res.key

    sleep 11
    res = @client.items.get(k)
    assert_nil res

  end

  def test_incrementors
    @client.cache_name = 'test_incrementors'
    clear_queue
    k = "incr1"
    v = 1
    res = @client.items.put(k, v)
    p res

    res = @client.items.get(k)
    p res
    assert_equal k, res.key
    assert_equal v, res.value

    incr_by = 10
    res = @client.items.increment(k, incr_by)
    res = @client.items.get(k)
    assert_equal v + incr_by, res.value

    res = @client.items.increment(k, -6)
    assert_equal 5, res.value

    res.delete

    # new style
    cache = @client.cache("test_incrementors")
    res = cache.put(k, v)
    p res

    res = cache.get(k)
    p res
    assert_equal k, res.key
    assert_equal v, res.value

    incr_by = 10
    res = cache.increment(k, incr_by)
    res = cache.get(k)
    assert_equal v + incr_by, res.value

    res = cache.increment(k, -6)
    assert_equal 5, res.value

    res.delete
  end

  def test_size
    cache = @client.cache("test_size")
    num_items = 100

    num_items.times do |i|
      res = cache.put("key-#{i}", "value")
    end

    puts "cache.size: #{cache.size}"
    assert_equal num_items, cache.size
  end


end

