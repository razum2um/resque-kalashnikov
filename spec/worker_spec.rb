require 'spec_helper'

DELAY = 0.5

describe 'Resque::Worker' do
  before do
    Resque.redis = Resque.redis # reset state in Resque object
    Resque.redis.flushall

    Resque.before_first_fork = nil
    Resque.before_fork = nil
    Resque.after_fork = nil
    @worker = Resque::Worker.new(:async_queue, :sync_queue)
    #@worker.verbose = true # useful to see sync/async difference
  end

  def async_server(response_status=200, delay=0)
    EM.synchrony do
      Resque.redis = EM::Hiredis.connect
      s = StubServer.new response_status, delay
      yield
      s.stop
    end
  end

  def now(); Time.now.to_f; end

  def get_url(attrs={})
    attrs = {n:0}.merge(attrs)
    "http://127.0.0.1:8081/?id=#{attrs[:n]}&kind=#{attrs[:kind]}"
    #"http://httplogger.herokuapp.com/bvlog/get?id=#{attrs[:n]}&kind=#{attrs[:method]}"
  end

  def create_async_job(attrs={})
    attrs.merge! kind: 'async'
    Resque::Job.create(:async_queue, SlowHttpRequest, get_url(attrs), attrs)
  end

  def create_sync_job(attrs={})
    attrs.merge! kind: 'sync'
    Resque::Job.create(:sync_queue, SlowHttpRequest, get_url(attrs), attrs)
  end

  it 'has proper name' do
    @worker.inspect.should =~ /KalashnikovWorker/
  end

  it 'makes acquires jobs with Hiredis#blpop' do
    create_sync_job
    @worker.reserve.should be_kind_of Resque::Job
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
    queue_size = 10
    queue_size.times { |n| create_async_job(n: n) }

    async_server(200, DELAY) do
      start = now
      @worker.work(0) do |job|
        # block yields in Worker#perform in "ensure" part
        #
        # this is too early - Fiber hasn't finished till this moment
        # if theirs count is small, it's still ok
        #
        # if there were 100 jobs - they'll have managed ~60
        # but uncommenting "if" statement leads to ever-hook in EM
        # having ~30 alive fibers after having done 100 jobs
        #
        # TLDR: kalashnikov-worker is hard to stop with block - use signals
        @worker.shutdown #if Resque.size(:async_queue) == 0
      end

      # O(1)
      (now - start).should be_within(DELAY*0.5).of(DELAY)
    end
  end

  it 'handles sync queues with processes' do
    queue_size = 10
    queue_size.times { |n| create_sync_job(n: n) }

    async_server(200, DELAY) do
      start = now
      @worker.work(0) do |job|
        @worker.shutdown if Resque.size(:sync_queue) == 0
      end

      # O(n)
      (now - start).should be_within(DELAY*queue_size*0.5).of(DELAY*queue_size)
    end
  end
end