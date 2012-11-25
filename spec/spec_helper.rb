require 'rubygems'
require 'resque'
#require 'webmock/rspec'
require 'em-synchrony'
require 'em-synchrony/em-hiredis'

$dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift $dir + '/../lib'
require 'resque_kalashnikov'
require 'support/stub_server'
$TESTING = true

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

class SlowHttpRequest < ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def handle http
    File.open("/tmp/kalashnikov-#{$$}.log", "a") do |f|
      f.write "#{DateTime.now}:#{http.response_header.status}:#{http.response}\n"
    end
  end
end
