require 'test_helper'

class QueueTest < MiniTest::Test
  setup do
    @name = 'testlist'

    @empty = fixture_file('empty')
    @mp3 = fixture_file('music.mp3')

    @media = GroupPlay::MediaFile.new(@mp3)
    @queue = GroupPlay::Queue.new(@name)
  end

  test "enqueue with invalid file" do
    @queue.enqueue @empty

    assert_equal [0,0], [@queue.data_list_size, @queue.file_list_size]
  end

  test "enqueue with valid file" do
    @queue.enqueue @mp3

    assert_equal [1,1], [@queue.data_list_size, @queue.file_list_size]
  end

  test "enqueue calls publish" do
    @queue.expects(:publish).once
    @queue.enqueue @mp3
  end

  test "data_list returns an array of strings" do
    2.times { @queue.enqueue @mp3 }

    assert_equal 2.times.map { @media.info.to_json }, @queue.data_list
  end

  test "dequeue returns data and file in array" do
    @queue.enqueue @mp3

    info, file = @queue.dequeue

    # NOTE we just compare file size; prevents terminal spam :)
    assert_equal [@media.info.to_json, @media.read.size], [info, file.size]
  end

  test "dequeue on empty returns nils" do
    assert_equal [nil, nil], @queue.dequeue
  end

  test "enqueue and dequeue is FIFO" do
    3.times do |n|
      GroupPlay::MediaFile.any_instance.stubs(:info).returns(title: n)
      GroupPlay::MediaFile.any_instance.stubs(:valid?).returns(true)

      @queue.enqueue(@mp3)
    end

    assert_equal %w[0 1 2], 3.times.map { @queue.dequeue.first[/\d+/] }
  end
end
