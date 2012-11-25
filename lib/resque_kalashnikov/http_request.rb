require "em-http-request"

module ResqueKalashnikov
  class HttpRequest
    attr_accessor :url, :method, :opts

    def initialize(*args)
      @url, @opts = args
      @opts ||= {}
      @method = @opts.delete('method') || 'get'
    end

    # This method is invoked inside EM
    # no blocking calls, please
    def perform
      puts "performing url=#{url} method=#{method} opts=#{opts}"
      f = Fiber.current
      http = EM::HttpRequest.new(url).get #send(method, opts)
      http.callback { f.resume(http) }
      http.errback  { f.resume(http) }
      handle Fiber.yield
    end

    def handle http
      http.response
    end

    class << self
      def perform(*args)
        new(*args).perform
      end
    end
  end
end
