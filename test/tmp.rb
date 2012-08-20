gem 'test-unit'
require 'test/unit'
require 'yaml'
require_relative 'test_base'

class IronCacheTests < TestBase
  def setup
    super
  end

  def test_keys
    @client.cache_name = 'test_keys'
    clear_queue

    k = "word_count_[EBook"
    v = "hello world!"
    res = @client.items.put(k, v)
    # another naming option we could try:
    #res = @client.cache('test_basics').items.put("key1", "hello world!")
    p res
    assert res.msg

  end

end

