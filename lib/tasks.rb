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
end
