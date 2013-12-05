require 'test_helper'

class MediaFileTest < MiniTest::Test
  setup do
    @mp3 = GroupPlay::MediaFile.new(fixture_file('music.mp3'))
    @empty = GroupPlay::MediaFile.new(fixture_file('empty'))
  end

  test 'mime_type is set for empty' do
    assert_equal 'inode/x-empty', @empty.mime_type
  end

  test 'encoding is set for empty' do
    assert_equal 'binary', @empty.encoding
  end

  test 'mime_type is set for mp3' do
    assert_equal 'audio/mpeg', @mp3.mime_type
  end

  test 'encoding is set for mp3' do
    assert_equal 'binary', @mp3.encoding
  end

  test 'info for empty' do
    assert_empty @empty.info
  end

  test 'info for mp3' do
    assert_equal %w[artist title album year genre], @mp3.info.keys
  end

  test 'image for empty' do
    assert_nil @empty.image
  end

  test 'image for mp3' do
    refute_nil @mp3.image
  end

  test 'valid? for empty is false' do
    assert_equal false, @empty.valid?
  end

  test 'valid? for mp3 is true' do
    assert_equal true, @mp3.valid?
  end
end
