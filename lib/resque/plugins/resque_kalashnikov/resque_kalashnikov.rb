#require 'net/http'
#require "em-synchrony/em-http"
#require 'em-http-request'

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

    def work_sync_on(job)
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

    def work_async_on(job)
      klass = job.payload_class
      args = job.payload['args']

      log "in fiber: class=#{klass.class} args=#{args}"
      klass.perform *args
    end

    def work_with_kalashnikov(interval=5.0, &block)
      interval = Float(interval)
      $0 = "resque: Starting Kalashnikov"
      startup

      loop do
        break if shutdown?

        if not paused? and job = reserve
          redis.client.reconnect
          log "got: #{job.inspect}"
          job.worker = self
          working_on job

          if job.queue['test_queue']
            work_async_on job
          else
            work_sync_on job
            @child = nil
          end

          done_working
        else
          break if interval.zero?
          log! "Sleeping for #{interval} seconds"
          procline paused? ? "Paused" : "Waiting for #{@queues.join(',')}"
          sleep interval
        end
      end

      unregister_worker
      EM.stop if no_workers_left?
    rescue Exception => exception
      log exception.backtrace.to_s
      unregister_worker(exception)
      EM.stop if no_workers_left?
    end

    def self.included(receiver)
      receiver.class_eval do
        alias work_without_kalashnikov work
        alias work work_with_kalashnikov
      end
    end
  end # ResqueKalashnikov
end # Resque::Plugins
