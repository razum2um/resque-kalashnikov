require 'resque/tasks'
require 'em-resque/tasks'

namespace :resque do
  task :setup

  desc "Fire Kalashnikov"
  task :fire do
    require 'resque'
    require 'resque_kalashnikov'
  end
end
