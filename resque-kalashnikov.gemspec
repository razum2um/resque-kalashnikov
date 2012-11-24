# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque_kalashnikov/version'

Gem::Specification.new do |gem|
  gem.name          = "resque-kalashnikov"
  gem.version       = ResqueKalashnikov::VERSION
  gem.authors       = ["Vlad Bokov"]
  gem.email         = ["bokov.vlad@gmail.com"]
  gem.summary       = %q{This is awesome}
  gem.description   = %q{Handles your HTTP requests in background in non-blocking way using Resque worker}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('resque', '~> 1.23.0')
  gem.add_dependency('redis', '> 3.0.0')
  gem.add_dependency('em-synchrony')
  gem.add_dependency('em-hiredis')
  gem.add_dependency('em-http-request')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('resque_spec')
end
