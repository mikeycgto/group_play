module GroupPlay
  EVENT_CHAN = "playlist_events_#{ENV['RACK_ENV'] || 'development'}"

  REDIS_OPT = {
    host: ENV['REDIS_HOST'] || 'localhost',
    port: ENV['REDIS_PORT'] || 6379,
    db: (ENV['REDIS_DB'] || 0).to_i,
  }

  module DataLine
    def redis
      @redis ||= Redis.new(REDIS_OPT)
    end

    def publish(ev, data = '{}')
      redis.publish EVENT_CHAN, "#{ev}/#{data}"
    end

    def subscribe(&block)
      redis.subscribe EVENT_CHAN do |on|
        on.message do |chan, json|
          index = json.index('/')
          event = json.slice!(0, index + 1)
          event.slice!(-1)

          block.call event, json, on
        end
      end
    end

    def unsubscribe
      redis.unsubscribe EVENT_CHAN
    end
  end
end

require 'group_play/version'

require 'group_play/queue'
require 'group_play/media_file'
