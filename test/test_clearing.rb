require 'test/unit'
require 'yaml'
require File.expand_path('test_base.rb', File.dirname(__FILE__))

class AboutClearing < TestBase
  def setup
    super
    @client.cache_name = 'test_clearing_incrementors'
  end

  def test_that_it_deletes_a_single_incrementor_FAILING
    clear_cache
    
    the_increment_key = "count"
    
    @client.items.increment the_increment_key
    
    clear_cache

    actual = @client.items.get(the_increment_key)

    assert_true actual.nil?, "Expected <nil>, actually got <#{actual.value}>"
  end

  def test_that_asking_for_a_missing_item_returns_nil
    assert_nil @client.items.get("xxx_nonsense_xxx"), "Just to show that we are right to expect nil"
  end
end

