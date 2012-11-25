module Resque::Plugins
  module ResqueKalashnikov

    def work_with_kalashnikov(interval=5.0, &block)
      interval = Float(interval)
      @fibers = []
      startup

      loop do
        break if shutdown?
        job = reserve

        log "got job in worker fiber: #{job.inspect}"
        job.worker = self

        working_on job

        if can_do_job_async? job
          @fibers << work_async_on(job, &block)
        else
          work_sync_on(job, &block)
          @child = nil
        end
        monitor(interval)
        done_working
      end
      unregister_worker

    rescue EM::ForcedStop => e
      # happens in fiber-mode
      # EM has stopped but we need 
      # to reconnect to report it
      Resque.redis = Redis.connect
      unregister_worker
    rescue Resque::Helpers::DecodeException => e
      # agian, happens in fork-mode
      raise e unless e.to_s['Redis disconnected']
      Resque.redis = Redis.connect
      unregister_worker

    rescue Exception => exception
      log exception.to_s
      log exception.backtrace.to_s
      unregister_worker(exception)
    end

    def inspect_with_kalashnikov
      "#<KalashnikovWorker #{to_s}>"
    end

    def work_sync_on(job, &block)
      log 'work sync'
      if @child = fork(job)
        srand # Reseeding
        procline "Forked #{@child} at #{Time.now.to_i}"
        begin
          Process.waitpid(@child)
        rescue SystemCallError
          nil
        end
        job.fail(DirtyExit.new($?.to_s)) if $?.signaled?
      else
        unregister_signal_handlers if will_fork? && term_child
        procline "Processing #{job.queue} since #{Time.now.to_i}"
        #reconnect # cannot do it with hiredis
        perform(job, &block)
        exit!(true) if will_fork?
      end
    end

    def work_async_on(job, &block)
      log "work async"
      Fiber.new do
        perform(job, &block)
      end.tap &:resume
    end

    # if resque worker gonna to stop - stop EM
    # essentially, fiber-singleton
    def monitor(interval)
      @monitor ||= Fiber.new do
        EM.add_periodic_timer(interval) do
          # monitor itself doesnt count in @fibers
          if (@fibers = @fibers.select(&:alive?)).empty?
            EM.stop if shutdown?
          else
            log "Big brother says: #{@fibers.size} fibers alive"
          end
        end
      end.tap &:resume
    end

    # test whenether we can do job async
    # based on its name
    def can_do_job_async?(job)
      !! job.queue['async']
    end

    def reserve_with_kalashnikov
      queues = Resque.queues.map { |q| "queue:#{q}" }

      # NO block for EM since using hiredis + em-synchrony
      queue, value = redis.blpop(*queues, 0)

      # shit happens if monitor fiber stops EM
      # it should happen only in tests
      raise EM::ForcedStop.new(queue) if queue['Redis disconnected']

      log "popped: q=#{queue} v=#{value}"
      payload = decode value
      Resque::Job.new queue, payload
    end

    def self.included(receiver)
      receiver.class_eval do
        alias work_without_kalashnikov work
        alias work work_with_kalashnikov

        alias inspect_without_kalashnikov inspect
        alias inspect inspect_with_kalashnikov

        alias reserve_without_kalashnikov reserve
        alias reserve reserve_with_kalashnikov
      end
    end
  end # ResqueKalashnikov
end # Resque::Plugins
