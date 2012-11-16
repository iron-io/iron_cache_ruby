require 'rest'
require_relative "iron_cache/version"
require_relative 'iron_cache/caches'
require_relative 'iron_cache/items'
require_relative 'iron_cache/client'

# session store
if defined? ActionDispatch
  require_relative 'action_dispatch/session/iron_cache'
end
