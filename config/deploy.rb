set :application, 'GroupPlay'

set :repo_url, 'git@github.com:mikeycgto/group_play.git'
set :scm, :git

set :deploy_to, '/home/groupplay/groupplay'
set :deploy_via, :remote_cache

set :format, :pretty
set :log_level, :debug
set :pty, true

set :stage, :production
set :user, 'groupplay'

server 'groupplay.local',
  user: 'groupplay',
  roles: %w{web app},
  ssh_options: { forward_agent: true }

def thin_command(bin, path)
  # TODO setup different log for each run
  "#{bin}/bin/thin --pid #{path}/tmp/thin.pid --log #{path}/log/thin.log --config #{path}/current/config/thin.yml -R #{path}/current/config.ru -e production"
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      if remote_file_exists?("#{deploy_to}/tmp/thin.pid")
        execute "#{thin_command shared_path, deploy_to} stop"
      end

      execute "#{thin_command shared_path, deploy_to} start"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "#{thin_command shared_path, deploy_to} stop"
    end
  end

  desc "Make thin directories"
  task :ensure_thin_dirs do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "mkdir -p #{deploy_to}/log #{deploy_to}/tmp"
    end
  end

  desc "Make app directories"
  task :ensure_app_dirs do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "mkdir -p #{deploy_to}/current/log"
    end
  end

  desc "Compile assets"
  task :assets do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "cd #{deploy_to}/current && bundle exec rake assets:precompile"
    end
  end

  # Hooks

  after :started, 'deploy:ensure_thin_dirs'

  before :restart, 'deploy:ensure_app_dirs'
  before :restart, 'deploy:assets'

  after :finishing, 'deploy:cleanup'
end
