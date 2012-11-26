require 'spec_helper'

describe Resque::Catridge do
  before do
    fake_redis = double
    fake_redis.stub(:rpush)
    fake_redis.stub(:hincrby)
    Resque::Catridge.stub(:redis).and_return(fake_redis)
  end

  def fake_response_with_status(status)
    response = double
    response.stub_chain(:response_header, :status).and_return(status)
    response
  end

  def fake_request
    request = double
    request.stub(:url).and_return 'some-url'
    request.stub(:reload_opts).and_return 'some-opts'
    request
  end

  def build(response)
    Resque::Catridge.new fake_request, response
  end

  it 'forces no reload on 200' do
    build(fake_response_with_status 200).reload?.should be_false
  end

  it 'forces 404 for reload' do
    build(fake_response_with_status 404).reload?.should be_true
  end

  it 'forces 500 for reload' do
    build(fake_response_with_status 500).reload?.should be_true
  end
end
