class SlowWorker
  @queue = :slow_queue
  def self.perform *args
    #EM::Synchrony.sleep 10
  end
end
