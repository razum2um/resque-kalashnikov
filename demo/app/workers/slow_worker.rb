class SlowWorker
  @queue = :slow_queue
  def self.perform *args
    sleep 20
  end
end
