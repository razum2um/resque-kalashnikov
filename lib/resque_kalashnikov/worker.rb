require 'resque_kalashnikov/http_request'

module ResqueKalashnikov
  class Worker
    attr_accessor :queue, :interval

    def initialize(queue, interval=1.0)
      @queue = queue
      @interval = interval

      ResqueKalashnikov.remove_queue queue
      Fiber.new &work
    end

    def pop_url
      puts "seeking in #{queue}"
      ResqueKalashnikov.redis.lpop queue
    end

    def sleep
      EM::Synchrony.sleep interval
    end

    def klass
      ResqueKalashnikov::HttpRequest
    end

    def work
      loop do
        unless klass.perform pop_url
          sleep
        end
      end
    end
  end
end
