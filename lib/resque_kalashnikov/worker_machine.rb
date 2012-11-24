require "em-synchrony"
require 'em-synchrony/em-hiredis'
require 'resque_kalashnikov/worker'

module ResqueKalashnikov
  class WorkerMachine

    attr_accessor :queues

    def initialize(opts = {})
      @queues = opts[:queues]

      if @queues.nil? || @queues.empty?
        raise "Please give each worker at least one queue."
      end
    end

    def start
      EM.synchrony do
        ResqueKalashnikov.redis = EM::Hiredis.connect
        fibers = queues.map { |q| ResqueKalashnikov::Worker.new q }
        fibers.map &:resume
      end
    end
  end
end
