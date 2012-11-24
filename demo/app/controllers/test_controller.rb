class TestController < ApplicationController
  layout false

  def home
    #5.times do
    #  Resque.enqueue Resque::Plugins::Kalashnikov, params[:method].upcase!, params[:url]
    #end
    redirect_to resque_server_path
  end

  def slow
    sleep 5
    render text: "[ok] test/slow: method: #{request.method} params: #{params}", content_type: 'text/plain'
  end

  def unreliable
    sleep 5
    if rand(10).even?
      render nothing: true, status: 500
    else
      render text: "[ok] test/unreliable: method: #{request.method} params: #{params}", content_type: 'text/plain'
    end
  end
end
