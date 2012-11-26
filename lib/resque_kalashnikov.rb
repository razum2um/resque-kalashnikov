require 'rubygems'
require 'em-synchrony'

require 'resque/worker'
require 'resque/catridge'
require "resque/plugins/resque_kalashnikov/resque_kalashnikov"
require "event_machine/forced_stop"
require "resque_kalashnikov/http_request"
require "resque_kalashnikov/railtie" if defined?(Rails)

module ResqueKalashnikov
  def kalashnikov_stats
    Resque::Catridge.stats
  end
end

Resque.extend ResqueKalashnikov
Resque::Worker.send(:include, Resque::Plugins::ResqueKalashnikov)
