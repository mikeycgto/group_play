require "test_helper"

class PlayerTest < MiniTest::Test
  setup do
    mock_audio!

    @queue = GroupPlay::Queue.new

    @player = GroupPlay::Player.new(log: logger)
    @player.start

    @mp3 = fixture_file("music.mp3")
  end

  test "next_track sets now playing" do
    @queue.enqueue(@mp3)
    @player.next_track

    refute_nil redis.get("now_playing")
  end

  test "next_track clears tempfile" do
    Dir['/tmp/gp*'].each { |file| File.unlink file }

    @queue.enqueue(@mp3)
    @player.next_track

    assert_empty Dir['/tmp/gp*']
  end

  test "next_track when queue empties sets now_playing to nil" do
    @queue.enqueue(@mp3)

    @player.next_track
    @player.next_track

    assert_nil redis.get("now_playing")
  end

  test "next_track when queue empties sets idle" do
    @queue.enqueue(@mp3)

    @player.next_track
    @player.next_track

    assert_equal true, @player.idle?
  end

  test "next_track with empty queue set idle to true" do
    @player.next_track

    assert_equal true, @player.idle?
  end

  test "next_track with empty queue keeps idle as true" do
    5.times { @player.next_track }

    assert_equal true, @player.idle?
  end

  test "next_track publishes with empty queue" do
    @player.expects(:publish).with('dequeue').once

    @player.next_track
    @player.next_track
  end

  test "next_track publishes event dequeue" do
    events = []

    @queue.enqueue(@mp3)

    @player.stubs(:publish).with { |*ev| events.push ev }
    @player.next_track

    assert_equal 'dequeue', events.first[0]
  end

  test "next_track publishes now_playing_time events" do
    events = []

    @queue.enqueue(@mp3)

    @player.stubs(:publish).with { |*ev| events.push ev }
    @player.next_track

    assert_equal 21, events.slice(1..-1).size
  end
end
