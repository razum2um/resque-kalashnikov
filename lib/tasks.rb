require 'resque/tasks'
#require 'resque_scheduler/tasks'
#require 'em-resque/tasks'

namespace :resque do
  task :setup

  desc "Fire Kalashnikov"
  task :fire do
    require 'resque_kalashnikov/worker_machine'

    queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')
    opts = {queues: queues}
    ResqueKalashnikov::WorkerMachine.new(opts).start
  end

  # use 
  #   rake resque:work
  # to start one worker

  task :kesque => [:preload, :setup] do
    require 'resque'
    require 'em-synchrony'
    require 'resque_kalashnikov'

    queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')

    EM.synchrony do
      # Redis 2
      #require 'redis'
      #
      #require "redis/connection/hiredis"   # won't send
      #require 'redis/connection/synchrony' # disconnects after 1st enqueue
      #
      #Resque.redis = Redis.new

      # Redis 3
      #Resque.redis = Redis.new(driver: :hiredis)   # won't send
      Resque.redis = Redis.new(driver: :synchrony) # send, disconnects after 3rd enqueue

      # Pure Hiredis
      #require "em-hiredis"                 # won't start - Resque is sync
      #require "em-synchrony/em-hiredis"    # disconnects after 3rd enqueue
      #Resque.redis = EM::Hiredis.connect

      #Resque.redis = EM::Synchrony::ConnectionPool.new(size: 10) do
      #   Resque.redis = Redis.new(driver: :synchrony) # send, disconnects after 3rd enqueue
      #
      #  EM::Hiredis.connect
      #  Redis.connect
      #end
      worker = Resque::Worker.new(*queues)
      worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
      worker.log "Starting worker #{worker}"
      worker.work(ENV['INTERVAL'] || 5)

      #opts = {queues: queues}
      #ResqueKalashnikov::WorkerMachine.new(opts).start

      ['TERM', 'INT', 'QUIT'].each { |signal| trap(signal) { worker.shutdown } }
    end
  end
end
