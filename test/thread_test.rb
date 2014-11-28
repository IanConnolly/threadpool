require "minitest/autorun"

require "threadpool"


class ThreadTest < Minitest::Unit::TestCase
  def test_size
    pool = Threadpool::Threadpool.new(workers: 4)
    assert_equal 4, pool.size
  end

  def test_threads_single_arg
    func = Proc.new do |list, value|
      list << value
    end
    pool = Threadpool::Threadpool.new(workers: 4)
    a = []
    pool.add_task(func, a, 4)
    
    loop {
      if pool.backlog == 0
        assert_equal [4], a
        break
      end
    }
  end

  def test_threads_multiple_args
    func = Proc.new do |list, *values|
      list.push(*values)
    end
    pool = Threadpool::Threadpool.new(workers: 4)
    a = []
    pool.add_task(func, a, 4, 5, 6, 7, 8)
    
    loop {
      if pool.backlog == 0
        assert_equal [4, 5, 6, 7, 8], a
        break
      end
    }
  end
end