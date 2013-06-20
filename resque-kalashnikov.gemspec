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

  gem.add_dependency('rake', '= 10.0.2')
  gem.add_dependency('addressable', '= 2.3.2')
  gem.add_dependency('multi_json', '= 1.3.7')
  gem.add_dependency('diff-lcs', '= 1.1.3')
  gem.add_dependency('resque', '= 1.23.0')
  gem.add_dependency('redis', '= 3.0.2')
  gem.add_dependency('tilt', '= 1.3.3')
  gem.add_dependency('em-http-request')
  gem.add_dependency('em-synchrony', '= 1.0.2')
  #gem.add_dependency('eventmachine', '= 1.0.0')
  gem.add_dependency('em-hiredis', '= 0.1.1')
  gem.add_dependency('redis-namespace', '= 1.2.1')
  gem.add_dependency('crack', '= 0.3.1')
  gem.add_dependency('em-socksify', '= 0.2.1')
  gem.add_dependency('rack', '= 1.4.1')
  gem.add_dependency('rack-protection', '= 1.2.0')

  gem.add_development_dependency('rack-test')
  gem.add_development_dependency('webmock', '= 1.9.0')
  gem.add_development_dependency('rspec', '= 2.12.0')
end
