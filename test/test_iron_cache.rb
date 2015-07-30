require 'test/unit'
require 'yaml'
require 'securerandom'
require File.expand_path('test_base.rb', File.dirname(__FILE__))

class IronCacheTests < TestBase
  def setup
    super
  end

  def test_basics
    @client.cache_name = 'test_basics'
    clear_cache

    k = "key1"
    v = "hello world!"
    res = @client.items.put(k, v)
    # another naming option we could try:
    #res = @client.cache('test_basics').items.put("key1", "hello world!")
    assert res.msg

    res = @client.items.get(k)
    assert res["key"]
    assert res.key
    assert_equal k, res.key
    assert_equal v, res.value

    res = @client.items.delete(res.key)
    res = @client.items.get(k)
    assert_nil res

    # new style of referencing cache
    cache = @client.cache("test_basics")
    res = cache.put(k, v)
    assert res.msg

    res = cache.get(k)
    assert res["key"]
    assert res.key
    assert_equal k, res.key
    assert_equal v, res.value

    res = cache.delete(k)
    res = cache.get(k)
    assert_nil res

    # test delete by item
    res = cache.put(k, v)
    assert res.msg

    res = cache.get(k)
    assert res.value
    res = res.delete
    res = cache.get(k)
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
    assert caches
    assert caches.is_a?(Array)
    assert caches.size > 0
    assert caches[0].name
    #assert caches[0].size

    cache = @client.caches.get(caches[0].name)
    assert cache.name
    #assert cache.size

    cache = @client.cache(caches[0])
    assert cache.name
    #assert cache.size
  end

  def test_expiry
    @client.cache_name = 'test_basics'
    clear_cache
    k = "key1"
    v = "hello world!"
    res = @client.items.put(k, v, :expires_in => 10)

    res = @client.items.get(k)
    assert_equal k, res.key

    sleep 11
    res = @client.items.get(k)
    assert_nil res
  end

  def test_cache_remove
    cache_name = 'test_delete'
    c = @client.cache(cache_name)
    c.put('any', 'to-create-cache')
    c.remove

    assert_raise do
      item = @client.caches.get(cache_name)
    end
  end

  def test_incrementors
    @client.cache_name = 'test_incrementors'
    clear_cache
    k = "incr1"
    v = 1
    res = @client.items.put(k, v)

    res = @client.items.get(k)
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

    res = cache.get(k)
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
    clear_cache(cache.name)
    num_items = 100

    num_items.times do |i|
      res = cache.put("key-#{i}", "value")
    end

    puts "cache.size: #{cache.size}"
    assert_equal num_items, cache.size
  end


  def test_keys
    @client.cache_name = 'test_keys'
    clear_cache

    k = "word_count_[EBook"
    v = "hello world!"
    res = @client.items.put(k, v)
    # another naming option we could try:
    #res = @client.cache('test_basics').items.put("key1", "hello world!")
    assert res.msg

  end


  def test_clear
    cache = @client.cache("test_clear_3")
    clear_cache(cache.name)

    num_items = 50

    num_items.times do |i|
      res = cache.put("key-#{i}", "value")
    end

    tkey = "key-0"
    assert_equal "value", cache.get(tkey).value

    cache.reload
    assert_equal num_items, cache.size

    p cache.clear
    sleep 2
    assert_nil cache.get(tkey)
    assert_equal 0, cache.reload.size
  end

  def test_add
    cache = @client.cache("test_add")
    cache.clear rescue ""
    udq_expires = 60 # 1 min
    k = 'mykey'
    r = cache.put(k, 0, :expires_in => udq_expires)
    r = cache.increment(k)
    assert_equal 1, r.value
    cache.put(k, 0, :add => true, :expires_in => udq_expires)
    r = cache.increment(k)
    assert_equal 2, r.value
    cache.put(k, 0, :add => true, :expires_in => udq_expires)
    r = cache.increment(k)
    assert_equal 3, r.value, "value is #{r.value}, expected 3"
  end

  def random_string(length)
    # SecureRandom.hex generates string of <len * 2>
    SecureRandom.hex(length/2)
  end

  def test_clear_delete_huge_cache
    # it creates number of cache items with big string keys and tries
    # to clear and to delete it. It is possible, that GCD backend will
    # fail due to overlimit in transaction.
    cache = @client.cache('test_clear_delete')
    assert_nothing_raised do
      clear_cache(cache.name)
    end

    item_value = 'we do not care about it in this test'
    transaction_limit = 1024 * 1024 # 1Mb
    icache_key_len_limit = 250 # symbols
    # Number of items to put to cache.
    # Sum of their keys' sizes must reach transaction limit.
    num_items = transaction_limit / icache_key_len_limit + 1
    cache_keys = num_items.times.map do
      k = random_string(icache_key_len_limit)
      cache.put(k, item_value)

      k
    end
    assert_equal item_value, cache.get(cache_keys.first).value
    assert_equal item_value, cache.get(cache_keys.last).value

    cache.reload
    assert_equal cache_keys.size, cache.size

    assert_nothing_raised do
      cache.clear
    end
    assert_nil cache.get(cache_keys.first)
    assert_nil cache.get(cache_keys.last)
    assert_equal 0, cache.reload.size

    cache_keys.each { |k| cache.put(k, item_value) }
    assert_equal item_value, cache.get(cache_keys.first).value
    assert_equal item_value, cache.get(cache_keys.last).value

    cache.reload
    assert_equal cache_keys.size, cache.size

    assert_nothing_raised do
      cache.remove
    end
    assert_raise do
      @client.caches.get(cache.name)
    end
  end
end
