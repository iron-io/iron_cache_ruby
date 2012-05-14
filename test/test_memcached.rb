gem 'test-unit'
require 'test/unit'
require 'yaml'
require 'memcache'
require_relative 'test_base'

class IronCacheMemcachedTests < TestBase
  def setup
    super

    @memcache = MemCache.new "#{IronCache::Client::AWS_US_EAST_HOST}:11211"

  end

  def test_basics_memcached
    puts "#{@client.token} #{@client.project_id}"

    #@memcache.get("abc")
    #@memcache.set("abc", "123")

    # auth format: "{token} {project ID} {cache name}"
    @memcache.set("oauth", "#{@client.token} #{@client.project_id} gem_tests", 0, true)
    k = 'abc'
    v = 'xyz'
    @memcache.set(k, v)

    ret = @memcache.get(k)
    p ret
    assert !ret.nil?
    assert ret == v

  end

  def test_expiry_memcached

  end

end

