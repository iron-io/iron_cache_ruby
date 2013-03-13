require 'rubygems'
require 'test/unit'
require 'yaml'
require 'uber_config'

unless Hash.instance_methods.include?(:default_proc=)
  class Hash
    def default_proc=(proc)
    end
  end
end

begin
  require File.join(File.dirname(__FILE__), '../lib/iron_cache')
rescue Exception => ex
  puts "Could NOT load current iron_cache: " + ex.message
  raise ex
end


class TestBase < Test::Unit::TestCase
  def setup
    puts 'setup'
    # check multiple config locations
    @config = UberConfig.load
    puts "config=" + @config.inspect
    @client = IronCache::Client.new(@config['iron'])
    @client.logger.level = Logger::DEBUG
    @client.cache_name = 'iron_cache_ruby_tests'

  end

  def clear_cache(cache_name=nil)
    cache_name ||= @client.cache_name
    puts "clearing cache #{cache_name}"
    cache = @client.cache(cache_name)
    cache.clear
    puts 'cleared.'
  end

  def assert_performance(time)
    start_time = Time.now
    yield
    execution_time =  Time.now - start_time
    assert execution_time < time, "Execution time too big #{execution_time.round(2)}, should be #{time}"
  end



end
