require 'rubygems'
require 'resque'
require 'em-synchrony'
require 'em-hiredis'
require 'em-synchrony/connection_pool'
require 'uri'

require "resque_kalashnikov/railtie" if defined?(Rails)

module ResqueKalashnikov
  extend Resque

  module ClassMethods
  def queue_ns
    :kqueue
  end

  def queues_ns
    :kqueues
  end

  def redis=(server)
    @redis = Redis::Namespace.new(:kalashnikov, :redis => server)
  end

  def push(queue, item)
    watch_queue(queue)
    redis.rpush "#{queue_ns}:#{queue}", encode(item)
  end

  # Pops a job off a queue. Queue name should be a string.
  #
  # Returns a Ruby object.
  def pop(queue)
    decode redis.lpop("#{queue_ns}:#{queue}")
  end

  # Returns an integer representing the size of a queue.
  # Queue name should be a string.
  def size(queue)
    redis.llen("#{queue_ns}:#{queue}").to_i
  end

  # Returns an array of items currently queued. Queue name should be
  # a string.
  #
  # start and count should be integer and can be used for pagination.
  # start is the item to begin, count is how many items to return.
  #
  # To get the 3rd page of a 30 item, paginatied list one would use:
  #   Resque.peek('my_list', 59, 30)
  def peek(queue, start = 0, count = 1)
    list_range("#{queue_ns}:#{queue}", start, count)
  end

  # Does the dirty work of fetching a range of items from a Redis list
  # and converting them into Ruby objects.
  def list_range(key, start = 0, count = 1)
    if count == 1
      decode redis.lindex(key, start)
    else
      Array(redis.lrange(key, start, start+count-1)).map do |item|
        decode item
      end
    end
  end

  # Returns an array of all known Resque queues as strings.
  def queues
    Array(redis.smembers(queues_ns))
  end

  # Given a queue name, completely deletes the queue.
  def remove_queue(queue)
    redis.srem(queues_ns, queue.to_s)
    redis.del("#{queue_ns}:#{queue}")
  end

  # Used internally to keep track of which queues we've created.
  # Don't call this directly.
  def watch_queue(queue)
    redis.sadd(queues_ns, queue.to_s)
  end

  def redis
    @redis || raise('redis must assingned inside EM loop')
  end
  end

  class << self
    include ClassMethods
  end
end
