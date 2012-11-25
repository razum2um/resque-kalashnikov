class TestWorker < ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def handle http
    puts "test worker: #{http.response_header.status}:#{http.response}"
  end
end
