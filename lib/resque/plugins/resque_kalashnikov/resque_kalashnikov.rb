module Resque::Plugins
  module ResqueKalashnikov

    def no_workers_left?
      Resque::Worker.all.count == 0
    end

    def em_queues
      queues & ['test_queue']
    end

    def non_em_queues
      queues - ['test_queue']
    end

    def work_sync_on(job, &block)
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
      klass = job.payload_class
      args = job.payload['args']

      log "in fiber: class=#{klass.class} args=#{args}"
      klass.perform *args
    end

    def can_async_job?(job)
      job.queue['async']
    end

    def job_fiber interval
      Fiber.new do
        loop do
          if job = reserve
            log! "got job in job fiber: #{job.inspect}"
            Fiber.yield job
          else
            break if paused?
            log! "Sleeping for #{interval} seconds"
            procline paused? ? "Paused" : "Waiting for #{@queues.join(',')}"
            sleep interval
          end
        end
        shutdown
      end
    end

    def work_with_kalashnikov(interval=5.0, &block)
      interval = Float(interval)
      $0 = "resque: Starting Kalashnikov"
      startup
      loop do
        job = job_fiber(interval).resume 

        log! "got job in worker fiber: #{job.inspect}"
        job.worker = self
        working_on job

        if can_async_job? job
          Fiber.new do
            work_async_on job, &block
          end.resume
        else
          work_sync_on job, &block
          @child = nil
        end
        done_working
      end
      unregister_worker
    rescue Exception => exception
      log! exception.to_s
      log! exception.backtrace.to_s
      unregister_worker(exception)
    end

    def self.included(receiver)
      receiver.class_eval do
        alias work_without_kalashnikov work
        alias work work_with_kalashnikov
      end
    end
  end # ResqueKalashnikov
end # Resque::Plugins
