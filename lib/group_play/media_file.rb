class GroupPlay::MediaFile
  INFO_KEYS = %w[artist title album year genre]

  def initialize(file)
    @file = file
    @tag_file = TagLib::FileRef.new(@file.path)
  end

  def mime_type
    @mime_type ||= Magic.guess_file_mime_type(@file.path)
  end

  def encoding
    @encoding ||= Magic.guess_file_mime_encoding(@file.path)
  end

  def info
    @info ||= parse_info
  end

  def image
    @image ||= parse_image
  end

  def read
    @file.seek 0
    @file.read
  end

  def valid?
    @valid ||= valid_mime? && valid_info?
  end

  protected

  def valid_mime?
    # TODO add application/octet-stream
    %w[
      audio/mpeg audio/mp4 application/octet-stream
    ].include?(mime_type)
  end

  def invalid_mime?
    !valid_mime?
  end

  def valid_info?
    !info['title'].nil? &&
    !info['artist'].nil? &&
    !info['title'].empty? &&
    !info['artist'].empty?
  end

  def parse_info
    return {} if invalid_mime? || @tag_file.null?

    tag = @tag_file.tag

    INFO_KEYS.inject({}) do |info, key|
      info.tap { info[key] = tag.send(key) }
    end
  end

  def parse_image
    return if invalid_mime? || @tag_file.null?

    mpeg = TagLib::MPEG::File.new(@file.path)
    apic = mpeg.id3v2_tag.frame_list('APIC').first

    if apic
      apic.picture
    end
  end
end
