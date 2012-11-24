class TestWorker
  extend ResqueKalashnikov::HttpRequest
  @queue = :test_queue
end
