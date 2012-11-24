require 'resque/tasks'
require 'resque_scheduler/tasks'
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
 
  task :kesque => [:preload, :setup] do
    require 'resque'
    require 'resque_kalashnikov'

    queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')

    EM.synchrony do
      Resque.redis = EM::Hiredis.connect
      worker = Resque::Worker.new(*queues)
      worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
      worker.log "Starting worker #{worker}"
      worker.work(ENV['INTERVAL'] || 5)

      ['TERM', 'INT', 'QUIT'].each { |signal| trap(signal) { worker.shutdown } }
    end
  end
end
