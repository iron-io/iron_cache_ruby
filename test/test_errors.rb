require 'test/unit'
require 'yaml'
require File.expand_path('test_base.rb', File.dirname(__FILE__))

class IronCacheTests < TestBase
  def setup
    super
  end

  def test_basics
    @client.cache_name = 'test_errors'
    clear_cache

    k = "key1"
    v = "hello world!"

    res = @client.items.get(k)
    p res

  end

end

