require 'resque_kalashnikov'
require 'resque/server'

module ResqueKalashnikov

  module Server

    def render_erb(view)
      erb File.read(File.join(File.dirname(__FILE__), view))
    end

    def self.included(base)
      base.class_eval do
        helpers do
          def format_time(t)
            t.strftime("%Y-%m-%d %H:%M:%S %z")
          end

          def queue_from_class_name(class_name)
            Resque.queue_from_class(Resque.constantize(class_name))
          end
        end

        get "/kalashnikov" do
          render_erb 'server/views/catridges.erb'
        end
      end
    end

    Resque::Server.tabs << 'Kalashnikov'
  end
end

Resque::Server.class_eval do
  include ResqueKalashnikov::Server
end
