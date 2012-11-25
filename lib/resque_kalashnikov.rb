require 'rubygems'
require 'em-synchrony'

require 'resque/worker'
require "resque/plugins/resque_kalashnikov/resque_kalashnikov"
require "event_machine/forced_stop"
require "resque_kalashnikov/http_request"
require "resque_kalashnikov/railtie" if defined?(Rails)

Resque::Worker.send(:include, Resque::Plugins::ResqueKalashnikov)
