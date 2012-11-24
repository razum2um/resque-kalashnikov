require "json"
require "em-synchrony/em-http"

module ResqueKalashnikov
  class HttpRequest < EventMachine::HttpRequest
    def self.perform(opts=nil)
      return unless opts

      opts = JSON.parse opts
      url = opts.delete 'url'
      method = opts.delete 'method'
      opts = opts

      http = EventMachine::HttpRequest.new(url).send(method, opts)
      http.callback { on_success }
      http.errback { on_failure }
      http
    end

    def self.on_success
      puts 'success'
    end

    def self.on_failure
      puts 'failure'
    end
  end
end
