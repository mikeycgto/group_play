require 'bundler'
Bundler.require :default, :test, :web

ENV['REDIS_DB'] = '2'
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'group_play'

require 'group_play/app'
require 'group_play/player'

require 'mocks/audio'

class MiniTest::Test
  include Rack::Test::Methods

  def app
    GroupPlay
  end

  def redis
    @redis ||= Redis.new({
      host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'].to_i
    })
  end

  def publish(ev, data = '{}')
    redis.publish(GroupPlay::EVENT_CHAN, "#{ev}/#{data}")
  end

  def logger
    @logger ||= Logger.new('/dev/null')
  end

  def teardown
    mocha_teardown

    redis.keys('testlist_*').each do |key|
      redis.del key
    end
  end

  def mock_audio!
    @audio_mock = Mocks::Audio.new
    @audio_mock.reset

    IO.stubs(:popen).returns(@audio_mock)
  end

  def fixture_file(fname)
    File.open File.join(File.expand_path('../fixture/files', __FILE__), fname)
  end

  def self.setup(&block)
    define_method 'setup', &block
  end

  def self.test(name, &block)
    define_method "test_#{name.gsub(/\s+/, '_')}", &block
  end
end

require 'mocha/setup'
