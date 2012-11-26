require 'rubygems'
require 'em-synchrony'

require "resque_kalashnikov/delegation"
require 'resque/worker'
require 'resque/catridge'
require "resque/plugins/resque_kalashnikov/resque_kalashnikov"
require "event_machine/forced_stop"
require "resque_kalashnikov/http_request"
require "resque_kalashnikov/railtie" if defined?(Rails)

module ResqueKalashnikov
  delegate :stats, :misfire_codes, :misfire_stats, :misfire_stats_reset, :reset_stats, to: Resque::Catridge, prefix: 'kalashnikov'
end

Resque.extend ResqueKalashnikov
Resque::Worker.send(:include, Resque::Plugins::ResqueKalashnikov)
