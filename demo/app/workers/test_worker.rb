class TestWorker < ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def handle http
    #sleep 10
    puts "test worker #{http.response_header.status}"
  end
end
