require 'test/unit'
require 'yaml'
require 'memcache'
require 'test_base'

class IronCacheMemcachedTests < TestBase
  def setup
    super

    @memcache = MemCache.new "#{@client.host}:11211"

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

    @memcache.delete(k)

    ret = @memcache.get(k)
    puts 'after delete: ' + ret.inspect
    assert ret.nil?

  end

  def test_expiry_memcached

  end

end

