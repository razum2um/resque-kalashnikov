require "em-synchrony/em-http"

module ResqueKalashnikov
  class HttpRequest
    attr_accessor :url, :http_method, :opts

    def initialize(*args)
      @url, @opts = args
      @opts ||= {}
      @http_method = @opts.delete('http_method') || 'get'
      @http_method.downcase!
    end

    # This method is invoked inside EM
    # no blocking calls, please
    def handle http
      Resque::Catridge.new(self, http)
    end

    def retry_limit
      3
    end

    def perform
      catrige = handle http_request
      reload if catrige.reload? && catrige.retries < retry_limit
      http_request.response
    end

    def reload_opts
      opts.merge http_method: http_method
    end

    private

    def reload
      Resque.enqueue self.class, url, reload_opts
    end

    def http_request
      EM::HttpRequest.new(url).send http_method, query: opts
    end

    def http_method
      valid_methods.include?(@http_method) ? @http_method : 'get'
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
