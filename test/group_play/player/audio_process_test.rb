require 'test_helper'

class AudioProcessTest < MiniTest::Test
  setup do
    mock_audio!

    @file  = Struct.new(:path).new('file.mp3')

    @audio = GroupPlay::AudioProcess.new(log: logger)
    @audio.start
  end

  test "load yields frames" do
    frames = []

    @audio.load(@file) do |cmd, *frame|
      frames.push(frame)
    end

    refute_empty frames
  end

  test "load yields frames with 4 floats" do
    frame = nil

    @audio.load(@file) do |f|
      frame = f unless frame
    end

    assert_equal [Float] * 4, frame.map { |f| f.class }
  end

  test "quit closes external process" do
    @audio.quit

    assert Mocks::Audio.instance.closed?
  end
end
