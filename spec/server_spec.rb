require 'spec_helper'
require "resque_kalashnikov/server"

ENV['RACK_ENV'] = 'test'

describe ResqueKalashnikov::Server do
  require 'rack/test'
  include Rack::Test::Methods

  def app
    Resque::Server
  end

  it 'has Kalashnikov tab' do
    get '/overview'
    last_response.body.should =~ /kalashnikov/
  end

  it 'can show Kalashnikov tab' do
    get '/kalashnikov'
    last_response.status.should == 200
  end

  describe 'actions' do
    before do
      @request_key = Base64.encode64 Resque.encode [SlowHttpRequest, [async_server_url, {method: 'post'}]]
      @fake_redis = double
      Redis.stub(:connect).and_return(@fake_redis)
    end

    it 'can retry jobs' do
      @fake_redis.should_receive(:rpush).once
      post '/kalashnikov/retry/500', {request_key: @request_key}
    end

    it 'can reset misfire count' do
      @fake_redis.should_receive(:rpush).once
      post '/kalashnikov/retry/500', {request_key: @request_key}
    end

    it 'can reset everyhing' do
      Resque::Catridge.should_receive(:reset_stats)
      get '/kalashnikov/reset_stats'
    end
  end
end
