gem 'test-unit'
require 'test/unit'
require 'yaml'
require_relative 'test_base'

class TestPerformance < TestBase
  def setup
    super
  end

  def test_performance_put_100_messages
    @client.cache_name = 'test_basics'
    assert_performance 10 do
      100.times do |i|
        res = @client.items.put("key", "value")
        puts "putting message #{res.inspect}"
      end
    end
  end

end
