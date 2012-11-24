require 'net/http'

module ResqueKalashnikov
  module HttpRequest

    extend self

    # This method is invoked inside running Fiber
    # you can leave blocking net/http
    def perform(*args)
      opts = args[0].dup

      url = opts.delete 'url'
      method = opts.delete('method') || 'get'
      opts = opts

      Net::HTTP.get URI.parse url
      #Resque.logger.info "failure: #{@http.response_header.status}\n#{@http.response_header}"
    end
  end
end
