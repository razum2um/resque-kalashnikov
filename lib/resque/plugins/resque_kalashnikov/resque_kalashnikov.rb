require 'em-synchrony/em-hiredis'

module Resque::Plugins
  module ResqueKalashnikov

    def hiredis
      return @hiredis if @hiredis
      self.hiredis = EM::Hiredis.connect
      puts "hiredis connected"
      self.hiredis
    end

    def work_with_kalashnikov(interval=5.0, &block)
      @fibers = []
      interval = Float(interval)
      $0 = "resque: Starting Kalashnikov"
      startup

      loop do
        break if shutdown?

        job = job_fiber(interval) #.resume 
        puts ">>>>>> job: #{job.inspect}"

        log "got job in worker fiber: #{job.inspect}"
        job.worker = self

        working_on job

        if can_do_job_async? job
          @fibers << work_async_on(job, &block)
        else
          work_sync_on job, &block
          @child = nil
        end
        done_working
      end
      unregister_worker
    rescue Exception => exception
      log exception.to_s
      log exception.backtrace.to_s
      unregister_worker(exception)
    end

    def inspect_with_kalashnikov
      "#<KalashnikovWorker #{to_s}>"
    end
    #private

    def work_sync_on(job, &block)
      puts 'sync'
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
        reconnect
        perform(job, &block)
        exit!(true) if will_fork?
      end
    end

    def work_async_on(job, &block)
      puts "async"
      #shutdown if Resque.size(:async_queue) == 0
      Fiber.new do
        perform job, &block
      end.tap &:resume
    end

    def can_do_job_async?(job)
      !! job.queue['async']
    end

    def job_fiber interval
      queues = Resque.queues.map { |q| "queue:#{q}" }
      #Fiber.new do
      #  loop do
          puts "job fiber loop, queues:#{queues}"

          #break if shutdown?
          #redis.info
          #puts "job fiber before blpop: #{hiredis.client.connected?}"
          queue, value = redis.blpop(*queues, 0) #.callback { |queue, value|
          puts "popped: q=#{queue} v=#{value}"
          payload = decode value
          job = Resque::Job.new queue, payload
          #Fiber.yield job
          #}


          #if job = reserve
          #  log "got job in job fiber: #{job.inspect}"
          #  Fiber.yield job
          #else
          #  break if paused?
          #  log "Sleeping for #{interval} seconds"
          #  procline paused? ? "Paused" : "Waiting for #{@queues.join(',')}"
          #  sleep interval
          #end
      #  end
      #  unregister_worker
      #end
    end

    # if resque gonna to stop - stop EM
    def unregister_worker_with_kalashnikov(exception=nil)
      unregister_worker_without_kalashnikov(exception)
      if @fibers
        EM.add_periodic_timer(1) do
          EM.stop if @fibers.none? &:alive?
        end
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        attr_accessor :hiredis

        alias work_without_kalashnikov work
        alias work work_with_kalashnikov

        alias inspect_without_kalashnikov inspect
        alias inspect inspect_with_kalashnikov

        alias unregister_worker_without_kalashnikov unregister_worker
        alias unregister_worker unregister_worker_with_kalashnikov
      end
    end
  end # ResqueKalashnikov
end # Resque::Plugins
