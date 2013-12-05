module GroupPlay
  class Queue
    include DataLine

    def initialize(name = 'playlist')
      @file_list = "#{name}_file"
      @data_list = "#{name}_data"
    end

    def enqueue(file)
      MediaFile.new(file).tap do |media|
        if media.valid?
          info_json = media.info.to_json

          redis.multi do
            redis.rpush @data_list, info_json
            redis.rpush @file_list, media.read
          end

          publish 'enqueue', info_json
        end
      end
    end

    def dequeue
      redis.multi do
        [redis.lpop(@data_list),
         redis.lpop(@file_list)]
      end
    end

    def data_list
      redis.lrange @data_list, 0, -1
    end

    def data_list_size
      redis.llen @data_list
    end

    def file_list_size
      redis.llen @file_list
    end

    alias :data_list_length :data_list_size
    alias :file_list_length :file_list_size
  end
end
