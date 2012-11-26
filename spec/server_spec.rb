require 'spec_helper'
require "resque_kalashnikov/server"

ENV['RACK_ENV'] = 'test'

require 'rack/test'
include Rack::Test::Methods

def app
  Resque::Server
end


describe ResqueKalashnikov::Server do
  it 'has Kalashnikov tab' do
    get '/overview'
    last_response.body.should =~ /kalashnikov/
  end

  it 'can show Kalashnikov tab' do
    get '/kalashnikov'
    last_response.status.should == 200
  end
end
