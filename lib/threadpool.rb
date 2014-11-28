require "threadpool/version"

module Threadpool
  class Threadpool
    def initialize(workers:)
      @work_queue = Queue.new
      @worker_threads = (0...workers).map do
        Thread.new do
          loop { 
            proc, args = @work_queue.pop
            proc.call(args)
          }
        end
      end
    end

    def backlog
      @work_queue.size
    end

    def size
      @worker_threads.length
    end

    def shutdown
      @worker_threads.map(&:join)
    end

    def add_task(f, *args)
      @work_queue << [f, args]
    end
  end
end
