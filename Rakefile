Bundler.require(:default)
require 'sinatra/asset_pipeline/task'

$:.unshift File.expand_path('../lib', __FILE__)

# Don't initialize audio player
ENV['NO_PLAYER'] = '1'

require 'group_play'
require 'group_play/app'

Sinatra::AssetPipeline::Task.define! GroupPlay::App

task :tux do
  system "bundle exec tux -c config.ru"
end

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
