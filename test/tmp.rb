gem 'test-unit'
require 'test/unit'
require 'yaml'
require_relative 'test_base'

class IronCacheTests < TestBase
  def setup
    super
  end


  def test_clear
    cache = @client.cache("test_clear")
    num_items = 50

    num_items.times do |i|
      res = cache.put("key-#{i}", "value")
    end

    tkey = "key-0"
    assert_equal "value", cache.get(tkey).value
    puts "cache.size: #{cache.size}"
    assert_equal num_items, cache.size

    p cache.clear
    assert_nil cache.get(tkey)
    assert_equal 0, cache.reload.size
  end

end

