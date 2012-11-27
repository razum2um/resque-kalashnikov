require "em-synchrony/em-http"

module ResqueKalashnikov
  class HttpRequest
    attr_accessor :url, :http_method, :opts

    def initialize(*args)
      case args.size
        when 1 then @url = args[0]
        when 2 then @url, @opts = args
        when 3 then @url, @http_method, @opts = args
      else
        raise "insufficient params in #{self.class}: args=#{args}"
      end
      @http_method ||= 'get'
      @opts ||= {}
      @http_method.downcase!
    end

    # This method is invoked inside EM
    # no blocking calls, please
    def handle http
      Resque::Catridge.new(self, http)
    end

    def retry_limit
      instance_variable_get(:@retry_limit) || 2
    end

    def perform
      catrige = handle http_request
      reload if catrige.reload? && catrige.retries < retry_limit
      http_request.response
    end

    def reload_opts
      opts
    end

    def http_method
      valid_methods.include?(@http_method) ? @http_method : 'get'
    end

    private

    def reload
      Resque.enqueue self.class, url, http_method, reload_opts
    end

    def http_request
      EM::HttpRequest.new(url).send http_method, query: opts
    end

    def valid_methods
      ['get', 'post', 'head', 'delete', 'put', 'options', 'patch']
    end

    class << self
      def perform(*args)
        new(*args).perform
      end
    end
  end
end
