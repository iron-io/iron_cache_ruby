gem 'test-unit'
require 'test/unit'
require 'yaml'
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
    @config = load_config
    puts "config=" + @config.inspect
    @client = IronCache::Client.new(@config['iron'])
    @client.logger.logger.level = Logger::DEBUG
    @client.cache_name = 'iron_cache_ruby_tests'

  end

  def load_config
    # check for config
    # First check if running in abt worker
    if defined? $abt_config
      @config = $abt_config
      return @config
    end
    cf = File.expand_path(File.join("~", "Dropbox", "configs", "iron_cache_ruby", "config.yml"))
    if File.exist?(cf)
      @config = YAML::load_file(cf)
      return @config
    end

  end


  def clear_queue(queue_name=nil)
    #queue_name ||= @client.cache_name
    #puts "clearing queue #{queue_name}"
    #while res = @client.messages.get(:cache_name=>queue_name)
    #  p res
    #  puts res.body.to_s
    #  res.delete
    #end
    #puts 'cleared.'
  end


end
