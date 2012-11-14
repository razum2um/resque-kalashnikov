module Resque
  module Plugins

    # job class that handles http requests
    class Kalashnikov

      @queue_name = :kalashnikov

      def self.perform(method, params)
        ::Logger.info "#{method} with #{params}"
      end
    end
  end
end
