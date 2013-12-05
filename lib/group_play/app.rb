require 'logger'
require 'pathname'

require 'group_play/player'

module GroupPlay
  class App < Sinatra::Base
    configure do
      set :root, File.expand_path('../../../', __FILE__)
      set :root_path, Pathname.new(root)

      set :views, settings.root_path.join('views')
      set :public_dir, settings.root_path.join('public')

      set :assets_css_compressor, :sass
      set :assets_precompile, %w[ application.css application.js vendor/angular.js vendor/event_source.js ]

      set :audio_log, ::Logger.new(settings.root_path.join('log', 'audio.log'))
      set :web_log, ::Logger.new(settings.root_path.join('log', 'web.log'))

      register Sinatra::AssetPipeline

      unless ENV['RACK_ENV'] == 'test' || ENV['NO_PLAYER'] == '1'
        set :player, Player.new({
          log: settings.audio_log, wait_time: 0.25
        })

        Thread.new do
          begin
            settings.player.tap do |player|
              player.start
              player.play_loop
            end
          rescue Exception => e
            puts e.message
            puts e.backtrace.join("\n")

            settings.audio_log.fatal "#{e.messages}"
            settings.audio_log.fatal "#{e.backtrace.join("\n")}"
          end
        end

        at_exit { player.quit }
      end
    end

    helpers do
      def redis
        @redis ||= Redis.new(REDIS_OPT)
      end

      def queue
        @queue ||= Queue.new
      end

      def playlist
        queue.data_list
      end

      def now_playing
        redis.get('now_playing') || 'null'
      end

      # This is something horrible; TagLib needs file extensions :(
      def move_file_with_extension(file)
        ext = file[:filename][/\.\w+\z/] || '.mp3'
        path = file[:tempfile].path

        dst = "#{path}#{ext}"

        FileUtils.mv path, dst
        File.new dst
      end
    end

    %w[ / /upload ].each do |path|
      get path do
        haml :index, layout: :application
      end
    end

    post '/enqueue/file' do
      logger.info "Got upload #{params[:file][:tempfile].size} #{params[:file][:tempfile].original_filename}"

      if params[:file] && params[:file][:tempfile]
        # First move the file to have the original extension
        tempfile = move_file_with_extension(params[:file])

        # Try to enqueue the file media file
        media_file = queue.enqueue(tempfile)

        # Remove the file
        #tempfile.delete

        if media_file.valid? then halt 204, ''
        else halt 400, '{"error":"Invalid File"}'
        end
      end
    end
  end
end
