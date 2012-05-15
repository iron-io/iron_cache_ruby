require File.expand_path('../lib/iron_cache/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Travis Reeder"]
  gem.email         = ["treeder@gmail.com"]
  gem.description   = "Ruby client for IronCache by www.iron.io"
  gem.summary       = "Ruby client for IronCache by www.iron.io"
  gem.homepage      = "https://github.com/iron-io/iron_cache_ruby"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "iron_cache"
  gem.require_paths = ["lib"]
  gem.version       = IronCache::VERSION

  gem.required_rubygems_version = ">= 1.3.6"
  gem.required_ruby_version = Gem::Requirement.new(">= 1.9")
  gem.add_runtime_dependency "iron_core"

  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "memcache-client"
  gem.add_development_dependency "uber_config"


end

