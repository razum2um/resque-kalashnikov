require 'eventmachine'

# thanks @igrigorik
# https://github.com/igrigorik/em-synchrony/blob/master/spec/helper/stub-http-server.rb
class StubServer
  module Server
    attr_accessor :responses, :delay
    def receive_data(data)
      EM.add_timer(@delay) {
        send_data @responses.sample
        close_connection_after_writing
      }
    end
  end

  def initialize(response_code=[200], delay=0, port=8081)
    @sig = EventMachine::start_server("127.0.0.1", port, Server) { |s|
      response_map = {
        "500" => "HTTP/1.0 500 Internal Server Error\r\nConnection: close\r\n\r\nFail: 500",
        "404" => "HTTP/1.0 404 Not Found\r\nConnection: close\r\n\r\nNot Found: 404",
        "200" => "HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nSuccess",
      }
      s.responses = response_map.select { |k,v| response_code.to_s.include? k } .values
      s.delay = delay
    }
  end

  def stop
    EventMachine.stop_server @sig
  end
end

if __FILE__ == $0
  EM.run do
    s = StubServer.new([200, 404, 500], 0)
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
