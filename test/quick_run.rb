require 'test_base'

class QuickRun < TestBase

  def setup
    super
    @client.cache_name = 'ironcache-gem-quick'
  end

  def test_basics
    key = "x"
    value = "hello world!"
    res = @client.items.put(key, value)
    p res
    assert res.msg

    res = @client.items.get(key)
    assert res.value
    assert res.value == value
    p res

    res = @client.items.delete(key)
    p res
    assert res.msg

    res = @client.items.get(key)
    p res
    assert res.nil?

  end


end

