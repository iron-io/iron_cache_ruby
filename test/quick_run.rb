# Put config.yml file in ~/Dropbox/configs/ironmq_gem/test/config.yml
require_relative 'test_base'

class QuickRun < TestBase

  def setup
    super
    @client.queue_name = 'ironmq-gem-quick'
  end

  def test_basics
    res = @client.items.post("hello world!")
    assert res.id
    assert res.msg
    p res

    res = @client.items.get()
    assert res.id
    assert res.body
    p res

    res = @client.items.delete(res["id"])
    assert res.msg
    p res

    res = @client.items.get()
    p res

  end


end

