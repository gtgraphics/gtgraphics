# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'gtgraphics'

# Git
set :repo_url, 'git@github.com:gtgraphics/gtgraphics.git'
set :ssh_options, forward_agent: true

# RVM
set :rvm_type, :user
set :rvm_ruby_version, '2.1.0'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml)

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets
                     vendor/bundle public/system)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Custom Roles
set :assets_roles, [:web, :app]
set :delayed_job_server_role, :worker

# Cronjobs
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

# Define Server
server 'gtgraphics.de', user: 'gtgraphics', roles: %w(web app db worker)

# Restart Server
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
    invoke 'delayed_job:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :updated, :fix_permissions do
    on roles(:web) do
      within release_path do
        execute :chmod, 700, :'bin/bundle'
        execute :chmod, 700, :'bin/rails'
        execute :chmod, 700, :'bin/delayed_job'
        execute :chmod, 700, :'bin/rake'
      end
    end
  end
end
