class SlowHttpRequest < ResqueKalashnikov::HttpRequest
  @queue = :async_queue
end
