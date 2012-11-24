class TestWorker
  extend ResqueKalashnikov::HttpRequest
  @queue = :async_queue

  def self.success
    #EM.synchrony.sleep 10
    #sleep 10
    Resque.logger.info 'ok'
  end
end
