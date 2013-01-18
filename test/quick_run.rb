require 'test_base'

class QuickRun < TestBase

  def setup
    super
  end

  def test_basics
    cache_name = 'ironcache-gem-quick'
    cache = @client.cache(cache_name)
    p cache
    key = "x"
    value = "hello world!"
    res = cache.put(key, value)
    p res
    assert res.msg
    puts "size: #{cache.size}"
    assert_equal 1, cache.size

    res = cache.get(key)
    p res
    assert_equal value, res.value

    res = cache.delete(key)
    p res
    assert res.msg

    res = cache.get(key)
    p res
    assert res.nil?

    cache.reload
    puts "size: #{cache.size}"
    assert_equal 0, cache.size

  end


end

