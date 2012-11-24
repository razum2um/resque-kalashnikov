require 'resque_kalashnikov'
require 'rails'

module ResqueKalashnikov
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'resque_kalashnikov/../tasks'
    end
  end
end
