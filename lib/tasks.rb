namespace :resque do

  desc "Fire Kalashnikov"
  task :fire do

    require 'resque'
    require 'em-synchrony'
    require 'em-synchrony/em-hiredis'
    require 'resque_kalashnikov'

    queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')

    # FIXME: cannot start with clean redis
    abort "QUEUE env var cannot be '*', please, list your queues" if queues.include? '*'
    redis = Redis.connect
    queues.each { |queue| redis.sadd "resque:queues", queue }


    if defined?(Rails) && Rails.respond_to?(:application)
      Rails.application.eager_load!
    end

    worker = Resque::Worker.new(*queues)
    #worker.verbose = true

    EM.synchrony do
      Resque.redis = EM::Synchrony::ConnectionPool.new(size: 100) do
        EM::Hiredis.connect
      end
      ['TERM', 'INT', 'QUIT'].each { |signal| trap(signal) { EM.stop } }
      worker.work(0)
    end
  end
end
