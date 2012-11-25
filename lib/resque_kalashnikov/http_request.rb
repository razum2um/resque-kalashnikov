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
    def perform
      handle EM::HttpRequest.new(url).send http_method, query: opts
    end

    def handle http
      http.response
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
