module GroupPlay
  class AudioProcess
    class Wait < Exception; end
    class NotRunning < Exception; end

    attr_reader :process, :pid, :wait_time

    def initialize(options)
      @running = false

      @logger = options[:log]
      @wait_time = options[:wait_time] || 0
    end

    def running?
      @running
    end

    def start
      return if running?

      @running = true
      @process = IO.popen('mpg123 -R on', mode: 'r+')
      @pid = @process.pid

      Process.detach(@pid)
    end

    def load(file)
      send_cmd "LOAD", file.path do |cmd, *line|
        # current frame, remaining frames,
        # current time, remaining time
        case cmd
        when '@F' then line.map!(&:to_f)
        when '@P'
          # TODO tighter integration with @P values?
          break if line[0] == '0'
        end

        yield line
      end
    end

    def pause
      send_cmd "PAUSE"
    end

    def quit
      send_cmd("QUIT")

      @running = false
      @process.close
    end

    protected

    def restart(ex)
      @running = false

      kill
      start
    end

    def kill
      Process.kill :KILL, @pid
    end

    # TODO maybe standardize IO errors?
    def send_cmd(cmd, *args)
      raise NotRunning.new('audio is not running') unless running?

      msg = "#{cmd} #{args * ' '}".strip

      @process.write "#{msg}\n"
      @process.flush

      @logger.debug "[AUDIO] sent: #{msg}"

      return readline unless block_given?

      while line = readline
        break if line.empty?

        yield line
      end
    rescue Errno::EPIPE => ex
      restart ex
    end

    def readline
      read = @process.gets.to_s.chomp
      line = read.split(' ')

      @logger.debug "[AUDIO] read: #{read}"

      return line

    rescue Errno::EPIPE => ex
      restart ex
    end
  end
end
