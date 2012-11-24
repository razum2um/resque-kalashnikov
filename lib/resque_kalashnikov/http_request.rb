require "json"
require "em-synchrony/em-http"

module ResqueKalashnikov
  module HttpRequest

    extend self

    def perform(*args)
      opts = args[0].dup

      @url = opts.delete 'url'
      @method = opts.delete('method') || 'get'
      @opts = opts

      #@http = EventMachine::HttpRequest.new(@url).send(@method, @opts)
      @http = EventMachine::HttpRequest.new('http://httplogger.herokuapp.com/bvlog/get?id=123').get
      @http.callback { on_success }
      @http.errback { on_failure }
    end

    def on_success
      Resque.logger.info 'success'
    end

    def on_failure
      Resque.logger.info 'failure'
    end
  end
end
