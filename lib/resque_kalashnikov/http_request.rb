#require "em-synchrony/em-http"
require 'em-http-request'

module ResqueKalashnikov
  module HttpRequest

    extend self

    def perform(*args)
      opts = args[0].dup

      @url = opts.delete 'url'
      @method = opts.delete('method') || 'get'
      @opts = opts

      @http = EM::HttpRequest.new(@url).send(@method, @opts)
      #@http = EM::HttpRequest.new('http://httplogger.herokuapp.com/bvlog/get?id=123').get
      @http.callback { success }
      @http.errback { failure }
    end

    def success
      Resque.logger.info "success"
    end

    def failure
      Resque.logger.info "failure: #{@http.response_header.status}\n#{@http.response_header}"
    end
  end
end
