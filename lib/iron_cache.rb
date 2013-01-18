require 'rest'
require "iron_cache/version"
require 'iron_cache/caches'
require 'iron_cache/items'
require 'iron_cache/client'

# session store
if defined? ActionDispatch
  require 'action_dispatch/session/iron_cache'
end
