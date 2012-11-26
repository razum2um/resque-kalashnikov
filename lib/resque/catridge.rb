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

    def retries
      self.class.redis.hget("#{self.class.ns}:misfires:#{status}", serialized_request).to_i
    end

    private

    def serialized_request
      Resque.encode([request.class.to_s, [request.url, request.reload_opts]])
    end

    def log
      self.class.redis.hincrby "#{self.class.ns}:misfires:#{status}", serialized_request, 1
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

      # DI here
      def redis
        Resque.redis
      end

      def stats
        redis.hgetall "#{ns}:stat"
      end

      def misfire_codes
        redis.keys "#{ns}:misfires:*"
      end

      def misfire_stats(status)
        redis.hgetall "#{status}"
        #redis.hgetall "#{ns}:misfires:#{status}"
      end

      def misfire_stats_reset(status, request)
        redis.hdel "#{status}", "#{request}"
        #redis.hgetall "#{ns}:misfires:#{status}"
      end

      def reset_stats
        redis.del "#{ns}:stat"
      end
    end
  end
end
