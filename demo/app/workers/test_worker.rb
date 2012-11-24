class TestWorker
  @queue = :test_queue

  def self.perform(*args)
    puts "oops: #{args}"
  end
end
