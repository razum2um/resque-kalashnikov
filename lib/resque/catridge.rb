module Resque
  class Catridge
    attr_reader :request, :response
    
    def initialize(request, response)
      @request = request
      @response = response
      log if misfire?
      inc_stat_counter
    end

    def reload?
      misfire? && !ran_out_of_ammo? 
    end

    private

    def log
      self.class.redis.rpush "#{self.class.ns}:misfires:#{status}", Resque.encode([request.url, request.reload_opts])
    end

    def inc_stat_counter
      self.class.redis.hincrby "#{self.class.ns}:stat", status, 1
    end

    def status
      @status ||= response.response_header.status
    end

    def misfire?
      case status
      when 500 then true
      when 404 then true
      else
        false
      end
    end

    def ran_out_of_ammo?
      # do something meaningfull
      false
    end

    class << self
      def ns
        'kalashnikov'
      end

      def redis
        Resque.redis
      end

      def stats
        redis.hgetall "#{ns}:stat"
      end

      def reset_stats
        redis.hgetall "#{ns}:stat"
      end
    end
  end
end
