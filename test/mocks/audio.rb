module Mocks
  class Audio
    def self.new
      @instance ||= super
    end

    def self.instance
      new
    end

    def self.reset
      instance.reset
    end

    attr_reader :pid

    def initialize
      @closed = false
      @pid = 0

      @input = nil
      @output = []
    end

    def reset
      initialize
    end

    def write(string)
      @input = string
    end

    def flush
      process_input!
    end

    def read_nonblock(maxlen)
      line = @output.first

      if line then line.slice!(maxlen)
      else raise GroupPlay::AudioProcess::Wait
      end
    end

    def gets
      @output.shift
    end

    def close
      @closed = true
    end

    def closed?
      @closed
    end

    protected

    def process_input!
      case @input
      when /^LOAD /
        @output.push(*create_frames(10, 0.5))
        @output.push("@P 0")
      end

      @input = nil
    end

    def create_frames(amount, step)
      [].tap do |frames|
        total = amount / step
        frame = 0

        while frame <= total
          frames << "@F #{frame} #{total - frame} #{frame * step} #{amount - (frame * step)}"

          frame += 1
        end
      end
    end
  end
end
