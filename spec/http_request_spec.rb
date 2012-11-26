require 'spec_helper'

describe 'ResqueKalashnikov::HttpRequest' do

  def build(attrs={})
    url = attrs.delete('url') || async_server_url
    ResqueKalashnikov::HttpRequest.new(url, attrs)
  end

  def success_response
    { :status => 200, :body => "success", :headers => {} }
  end

  ['get', 'post', 'delete', 'put'].each do |http_method|
    it "stores valid #{http_method} methods" do
      stub_request(http_method.to_sym, async_server_url).to_return success_response
      EM.synchrony do
        build("http_method" => http_method).send(:http_request).response.should == 'success'
        EM.stop
      end
    end
  end

  ['head', 'options', 'patch'].each do |http_method|
    it "stores valid #{http_method} methods" do
      stub_request(http_method.to_sym, async_server_url).to_return success_response
      EM.synchrony do
        build("http_method" => http_method).send(:http_request).response.should == ''
        EM.stop
      end
    end
  end

  it 'stores invalid methods as GET' do
    stub_request(:get, async_server_url).to_return success_response
    EM.synchrony do
      build.send(:http_request).response.should == 'success'
      build('http_method' => 'foobar').send(:http_request).response.should == 'success'
      EM.stop
    end
  end

  it 'handles misc options' do
    stub_request(:get, async_server_url)
      .with(:query => {"a" => ["b", "c"], "d" => "e"})
      .to_return(success_response)

    stub_request(:post,  "http://127.0.0.1:8081/?d=e&n=1&kind=async")
      .to_return(success_response)

    EM.synchrony do
      build(
        "a" => ["b", "c"],
        "d" => "e"
      ).send(:http_request).response.should == 'success'

      build(
        "url" => async_server_url({n: 1, kind: 'async'}),
        "http_method" => "post",
        "d" => "e"
      ).send(:http_request).response.should == 'success'
      EM.stop
    end
  end

  describe 'error handling' do
    it 'handles 4xx responses' do
      stub_request(:any, async_server_url).to_return(:status => [404, "Not Found"])
      EM.synchrony do
        build.send(:http_request).response_header.status.should == 404
        EM.stop
      end
    end

    it 'handles 5xx responses' do
      stub_request(:any, async_server_url).to_return(:status => [500, "Internal Server Error"])
      EM.synchrony do
        build.send(:http_request).response_header.status.should == 500
        EM.stop
      end
    end
  end
end
