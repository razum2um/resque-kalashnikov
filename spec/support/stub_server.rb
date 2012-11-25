require 'eventmachine'

# thanks @igrigorik
# https://github.com/igrigorik/em-synchrony/blob/master/spec/helper/stub-http-server.rb
class StubServer
  module Server
    attr_accessor :response, :delay
    def receive_data(data)
      EM.add_timer(@delay) {
        send_data @response
        close_connection_after_writing
      }
    end
  end

  def initialize(response_code=200, delay=0, port=8081)
    @sig = EventMachine::start_server("127.0.0.1", port, Server) { |s|
      s.response = case response_code
        when 200 then "HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nSuccess"
      end
      s.delay = delay
    }
  end

  def stop
    EventMachine.stop_server @sig
  end
end

if __FILE__ == $0
  EM.run do
    s = StubServer.new(200, 0)
    puts 'Started on http://localhost:8081/'

    ['TERM', 'INT', 'QUIT'].each do |signal|
      trap(signal) do
        puts 'Finished'
        s.stop
        EM.stop
      end
    end
  end
end
