require 'minitest/autorun'
require 'threadpool'

class ThreadTest < Minitest::Unit::TestCase
  def setup
    @pool = Threadpool::Threadpool.new(workers: 4)
  end

  def test_size
    assert_equal 4, @pool.size
  end

  def test_threads_single_arg
    func = Proc.new do |list, value|
      list << value
    end
    a = []
    @pool.add_task(func, a, 4)

    loop do
      if @pool.backlog == 0
        assert_equal [4], a
        break
      end
    end
  end

  def test_threads_multiple_args
    func = Proc.new do |list, *values|
      list.push(*values)
    end
    a = []
    @pool.add_task(func, a, 4, 5, 6, 7, 8)

    loop do
      if @pool.backlog == 0
        assert_equal [4, 5, 6, 7, 8], a
        break
      end
    end
  end

  def test_shutdown
    @pool.shutdown!
    assert_equal @pool.shutdown?, true
    assert_raises Threadpool::ShutdownError do
      @pool.backlog
    end
  end
end
