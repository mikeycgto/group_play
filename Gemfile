source 'https://rubygems.org'

gem 'redis'
gem 'thin'

gem 'haml'

gem 'sass'
gem 'compass'

gem 'sinatra', require: 'sinatra/base', github: 'sinatra/sinatra'
gem 'sinatra-asset-pipeline', require: 'sinatra/asset_pipeline'

gem 'magic'
gem 'taglib-ruby', require: 'taglib'

gem 'yajl-ruby', require: 'yajl/json_gem'

group :test do
  gem 'minitest', require: false
  gem 'mocha', require: false

  gem 'jasmine'
end

group :development do
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-jasmine-headless-webkit'
  #gem 'guard-jasmine'

  gem 'tux'

  # For deploying
  gem 'capistrano', '~> 3.0.0', require: false
  gem 'capistrano-bundler', require: false

  # For password prompts
  gem 'highline'
end

