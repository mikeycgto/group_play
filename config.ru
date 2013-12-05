$:.unshift File.expand_path('../lib', __FILE__)
Bundler.require :default, :web

require 'group_play'
require 'group_play/app'
require 'group_play/stream'

def app
  Rack::URLMap.new({
    '/'          => GroupPlay::App,
    '/subscribe' => GroupPlay::Stream
  })
end

run app
