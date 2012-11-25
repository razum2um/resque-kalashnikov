require 'spec_helper'

describe 'Resque::Worker' do
  before do
    Resque.redis = Resque.redis # reset state in Resque object
    Resque.redis.flushall

    Resque.before_first_fork = nil
    Resque.before_fork = nil
    Resque.after_fork = nil
    @worker = Resque::Worker.new(:async_queue, :sync_queue)

  end

  let (:tz)         { Time.now.to_i }
  def get_url(attrs={})
    attrs = {n:0}.merge(attrs)
    "http://httplogger.herokuapp.com/bvlog/get?id=#{attrs[:n]}&method=#{attrs[:method]}"
  end

  def create_async_job(attrs={})
    attrs.merge! method: 'async'
    Resque::Job.create(:async_queue, SlowHttpRequest, get_url(attrs), attrs)
  end

  def create_sync_job(attrs={})
    attrs.merge! method: 'sync'
    Resque::Job.create(:sync_queue, SlowHttpRequest, get_url(attrs), attrs)
  end

  it 'has proper name' do
    @worker.inspect.should =~ /KalashnikovWorker/
  end

  it 'makes job fiber produce jobs' do
    create_sync_job
    @worker.job_fiber(0).resume.should be_kind_of Resque::Job
  end

  it 'differs async jobs' do
    create_async_job
    @worker.can_do_job_async?(Resque::Job.reserve :async_queue).should be_true
  end

  it 'differs sync jobs' do
    create_sync_job
    @worker.can_do_job_async?(Resque::Job.reserve :sync_queue).should be_false
  end

  it 'handles async queues with fibers' do
    queue_size = 50
    #stub_request(:get, get_url).to_return(:body => 'foobar')
    queue_size.times { |n| create_async_job(n: n) }

    require 'em-synchrony/em-hiredis'
    EM.synchrony do
      #Resque.redis = Redis.new(driver: :hiredis)
      Resque.redis = EM::Hiredis.connect
      #start = now
      #x = EM::HttpRequest.new('http://httplogger.herokuapp.com/bvlog/get').get #send(method, opts)
      #x.callback { puts x.response; EM.stop }
      @worker.work(0) do |job|
        #@worker.shutdown if Resque.size(:async_queue) == 0
      end
      create_async_job(n: 51)
      #(now - start).should be_within(DELAY*0.15).of(DELAY)
    end
  end

  it 'handles sync queues with processes' do
    queue_size = 5
    #stub_request(:get, get_url).to_return(:body => 'foobar')
    queue_size.times { |n| create_sync_job(n: n) }

    start = now
    @worker.work(2) do |job|
      @worker.shutdown if Resque.size(:sync_queue) == 0
    end
    (now - start).should be_within(DELAY * 0.15).of(DELAY)
  end
end
