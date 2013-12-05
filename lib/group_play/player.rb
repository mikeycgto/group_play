require 'group_play/player/audio_process'

module GroupPlay
  class Player
    attr_reader :audio, :logger, :running

    include DataLine

    def initialize(options)
      @options = options
      @logger  = options[:log]

      @audio = AudioProcess.new(options)
      @queue = Queue.new

      @idle = false
    end

    def idle?
      @idle
    end

    def play_loop(huh = nil)
      audio.start unless audio.running?

      while !idle?
        next_track
      end

      wait_for_enqueue
    end

    def next_track
      logger.info "[NEXT] Loading next track"
      logger.debug "queues: #{@queue.data_list_size} #{@queue.file_list_size}"

      self.now_playing = @queue.dequeue
    end

    def wait_for_enqueue
      logger.info "[IDLE] Waiting for next enqueue"

      while idle?
        @idle = @queue.data_list_size < 1

        sleep 1
      end

      return play_loop # return to play loop
    end

    def quit
      logger.info "[QUIT] Closing audio process"
      # TODO stop audio and remove if playing

      audio.quit
    end

    def start
      logger.info "[START] Begining audio process"

      audio.start
    end

    protected

    def running?
      @audio.running?
    end

    def now_playing=(track)
      was_idle = @idle
      info, data = track

      @idle = info.nil? || data.nil?
      return if @idle && was_idle

      publish 'dequeue'

      if idle?
        logger.info "[IDLE] Player is now idle"
        logger.debug "info: #{info.nil?} data: #{data.nil?}"

        redis.del 'now_playing'

      else
        logger.info "[PLAY] Player is now loading audio"
        logger.info "size: #{info.size} bytes"

        redis.set 'now_playing', info

        load_audio write_tempfile(data)
      end
    end

    def write_tempfile(data)
      logger.info "[PLAY] Writing Audio File"
      logger.debug "size: #{data.size / 1048576.0} MB"

      Tempfile.new('gp-data').tap do |file|
        file.write data
        file.flush
        file.close
        file
      end
    end

    def load_audio(file)
      logger.info "[PLAY] Loading audio on process"
      logger.debug "filename: #{file.path}"

      duration = nil, last = nil

      audio.load file do |fr, rfr, tm, rtm|
        break if fr == '@P' # play has ended

        if duration.nil?
          duration = tm + rtm

          logger.debug "duration: #{duration}"
        end

        if last.nil? || last - 1 < rtm
          publish 'now_playing_time', {
            duration: duration, time: tm
          }.to_json
        end
      end

      logger.info "[PLAY] Removing audio file from tmp"
      logger.debug "filename: #{file.path}"

      file.delete
    end
  end
end
