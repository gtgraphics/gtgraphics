set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

# Application
set :application, 'templerclan'
set :user, application
set :use_sudo, false

# Server
server 'gtgraphics.de', :app, :web, :db, primary: true

# SCM
set :scm, :git
set :repository, "git@tasdy.net:#{application}"
set :deploy_via, :remote_cache
set :deploy_to do
  "/home/#{user}/webapps/#{application}/#{rails_env}"
end

# SSH
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
default_run_options[:shell] = false

# RVM configuration
set :rvm_ruby_string, :local
require "rvm/capistrano"

# Bundler configuration
require "bundler/capistrano"

# Custom Tasks
namespace :db do
  task :create_symlink do
    #run "rm #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

# Tasks for Passenger
namespace :deploy do
  task :start do
    # do nothing
  end
  task :stop do
    # do nothing
  end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

# Hooks
after "deploy:finalize_update", "db:create_symlink"