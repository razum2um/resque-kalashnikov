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

        post "/kalashnikov/retry/:status" do
          status = params[:status]
          klass_name, args = Resque.decode Base64.decode64 params[:request_key]
          klass = Resque::Job.constantize klass_name
          queue = Resque.queue_from_class(klass)
          redis = Redis.connect
          redis.rpush "resque:queue:#{queue}", Resque.encode(:class => klass_name, :args => args)
          redirect u('/kalashnikov')
        end

        post "/kalashnikov/reset/:status" do
          status = params[:status]
          request_key = Base64.decode64 params[:request_key]
          redis = Redis.connect
          redis.hset "resque:kalashnikov:misfires:#{status}", request_key, 0
          redirect u('/kalashnikov')
        end
      end
    end

    Resque::Server.tabs << 'Kalashnikov'
  end
end

Resque::Server.class_eval do
  include ResqueKalashnikov::Server
end
