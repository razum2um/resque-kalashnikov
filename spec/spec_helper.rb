require 'rubygems'
require 'resque'
#require 'webmock/rspec'
require 'eventmachine'

$dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift $dir + '/../lib'
require 'resque_kalashnikov'
$TESTING = true

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

DELAY = 5 #0.25

class SlowHttpRequest < ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def handle http
    File.open('/tmp/1', 'a'){ |f| f.write http.response_header.status }
    puts http.response
    #sleep DELAY
    #puts http.response_header.status
  end
end

def now(); Time.now.to_f; end
