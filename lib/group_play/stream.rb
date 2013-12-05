class GroupPlay::Stream < Sinatra::Base
  configure do
    extend GroupPlay::DataLine

    mime_type :stream, 'text/event-stream'

    set :clients, []
    set :redis, redis

    Thread.new do
      subscribe do |event, json|
        msg = "event: #{event}\ndata: #{json}\n\n"

        settings.clients.each { |out| out << msg }
      end
    end
  end

  get '*' do
    content_type :stream

    stream(:keep_open) do |out|
      settings.clients << out

      out.callback { settings.clients.reject!(&:closed?) }
      out.errback  { out.close }
    end
  end
end
