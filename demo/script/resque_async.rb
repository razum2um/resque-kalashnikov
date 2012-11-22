RAILS_ENV = ENV['RAILS_ENV'] || 'development_async'
RAILS_ROOT = Dir.pwd

require 'rubygems'
require 'yaml'
require 'uri'
require 'em-resque'
require 'em-resque/worker_machine'
require 'em-resque/task_helper'

#require 'resque-kalashnikov'
#require 'resque/plugins/kalashnikov'
require '/www/resque-kalashnikov/lib/resque/plugins/kalashnikov'

#require 'resque-retry'
#require 'em-synchrony'
#require 'em-synchrony/connection_pool'
#require 'em-synchrony/mysql2'

require 'debugger'

#Dir.glob(File.join(RAILS_ROOT, 'lib', 'async_worker', '**', '*.rb')).sort.each{|f| require File.expand_path(f)}

#resque_config = YAML.load_file("#{RAILS_ROOT}/config/resque.yml")
#proxy_config = YAML.load_file("#{RAILS_ROOT}/config/proxy.yml")
#PROXY = proxy_config ? proxy_config[RAILS_ENV] : nil

opts = TaskHelper.parse_opts_from_env #.merge(:redis => resque_config[RAILS_ENV])
EM::Resque::WorkerMachine.new(opts).start
