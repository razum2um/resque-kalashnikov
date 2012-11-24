require 'rubygems'
require 'resque'
require 'resque/worker'
require 'resque-dynamic-queues'
require "resque_kalashnikov/http_request"
require "resque/plugins/resque_kalashnikov/resque_kalashnikov"
require "resque_kalashnikov/railtie" if defined?(Rails)

Resque::Worker.send(:include, Resque::Plugins::ResqueKalashnikov)
