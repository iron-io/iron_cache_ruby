require File.expand_path('test_base.rb', File.dirname(__FILE__))

class QuickRun < TestBase

  def setup
    super
  end

  #def test_loader
  #  cache_name = 'ironcache-load'
  #  cache = @client.cache(cache_name)
  #  p cache
  #  100.times do |i|
  #    p i
  #    key = "x"
  #    value = "hello world!"
  #    res = cache.put(key, value)
  #    p res
  #    assert res.msg
  #  end
  #
  #  cache.reload
  #  puts "size: #{cache.size}"
  #  assert_equal 100, cache.size
  #
  #end

  def test_unloader
    cache_name = 'ironcache-load'
    cache = @client.cache(cache_name)
    p cache
    assert_equal 201, cache.size
    res = cache.get("x")
    p res
    value = "hello world!"
    assert_equal value, res.value

    100.times do |i|
      p i
      key = "x#{i}"
      res = cache.put(key, value)
      #p res
      assert res.msg
    end

    cache.reload
    puts "size: #{cache.size}"
    assert_equal 201, cache.size

    res = cache.put("randomyo", value)
    assert_equal 202, cache.reload.size

  end


end

