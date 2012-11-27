class TestController < ApplicationController
  layout false

  def home
    100.times do |n|
      Resque.enqueue SlowHttpRequest, "http://httplogger.herokuapp.com/bvlog/get?n=#{n}", :get
      #Resque.enqueue SlowHttpRequest, "http://httplogger.herokuapp.com/bvlog/get?n=#{n}", :get, {error: 404}
    end
    120.times do |n|
      Resque.enqueue SlowHttpRequest, "http://httplogger.herokuapp.com/bvlog/post?n=#{n}", :post, {n10: n*10}
      #Resque.enqueue SlowHttpRequest, "http://httplogger.herokuapp.com/bvlog/post?n=#{n}", :post, {error: 500}
    end
    redirect_to '/resque/kalashnikov'
  end
end
