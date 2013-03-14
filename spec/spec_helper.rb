require 'rubygems'
require 'resque'
require 'em-synchrony'
require 'em-synchrony/em-hiredis'
require 'webmock/rspec'
require 'coveralls'
Coveralls.wear!

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

  config.before do
    Redis.connect.flushall
  end
end

class SlowHttpRequest < ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def handle http
    super
    File.open("/tmp/kalashnikov-#{$$}.log", "a") do |f|
      f.write "#{DateTime.now}:#{http.response_header.status}:#{http.response}\n"
    end
  end
end

def async_server(response_status=200, delay=0)
  WebMock.allow_net_connect!
  EM.synchrony do
    #EM::HttpRequest.new('http://httplogger.herokuapp.com/bvlog/clear').get if async_server_url['herokuapp']
    Resque.redis = EM::Synchrony::ConnectionPool.new(size: 3) do
      EM::Hiredis.connect
    end
    #Resque.redis.flushall # reset state in Resque object
    s = StubServer.new response_status, delay
    yield
    s.stop
  end
end

def async_server_url(attrs={})
  #return "http://httplogger.herokuapp.com/bvlog/get"
  if attrs.empty?
    "http://127.0.0.1:8081"
  else
    "http://127.0.0.1:8081/?n=#{attrs[:n]}&kind=#{attrs[:kind]}"
  end
end
