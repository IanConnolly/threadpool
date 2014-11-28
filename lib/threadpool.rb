require "threadpool/version"

module Threadpool

  class ShutdownError < StandardError
  end

  class Threadpool
    def initialize(workers:)
      @shutdown = false
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
      raise ShutdownError, "Threadpool already shutdown" if shutdown?
      @work_queue.size
    end

    def size
      raise ShutdownError, "Threadpool already shutdown" if shutdown?
      @worker_threads.length
    end

    def shutdown?
      @shutdown
    end

    def shutdown!(timeout: 0.2)
      raise ShutdownError, "Threadpool already shutdown" if shutdown?
      @worker_threads.map { |t|  
        t.join timeout
      }
      @shutdown = true
    end

    def add_task(f, *args)
      raise ShutdownError, "Threadpool already shutdown" if shutdown?
      @work_queue << [f, args]
    end
  end
end
