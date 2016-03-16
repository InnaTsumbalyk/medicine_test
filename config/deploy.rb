# config valid only for current version of Capistrano
lock '3.4.0'

set :repo_url, 'git@github.com:InnaTsumbalyk/medicine_test.git'
set :application, 'medicine'
application = 'medicine'
set :rvm_type, :user
# set :rvm_ruby_version, '2.0.0-p353'
set :deploy_to, '/home/deployer/apps/medicine'

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads')

namespace :git do
  desc 'Deploy'
  task :deploy do
    ask(:message, "Commit message?")
    run_locally do
      execute "git add -A"
      execute "git commit -m '#{fetch(:message)}'"
      execute "git push"
    end
  end
end

namespace :deploy do
  desc 'Setup'
  task :setup do
    on roles(:all) do
      execute "mkdir  #{shared_path}/config/"
      execute "mkdir  /home/deployer/apps/#{application}/log/"
      execute "mkdir #{shared_path}/system"

      upload!('shared/database.yml', "#{shared_path}/config/database.yml")
      upload!('shared/nginx.conf', "#{shared_path}/nginx.conf")
      # sudo rm /etc/nginx/sites-enabled/default
      sudo "rm /etc/nginx/sites-enabled/default"
      sudo "ln -nfs #{shared_path}/nginx.conf /etc/nginx/sites-enabled/#{application}"
      sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    end
  end

  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      execute "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end

  task :restart do
    # invoke 'unicorn:stop'
    # invoke 'unicorn:start'
    sudo "service unicorn_#{application} stop"
    sudo "service unicorn_#{application} start"
  end

  task :restart_nginx_config do
    on roles(:all) do
      upload!('shared/nginx.conf', "#{shared_path}/nginx.conf")
      # sudo rm /etc/nginx/sites-enabled/default
      sudo "ln -nfs #{shared_path}/nginx.conf /etc/nginx/sites-enabled/#{application}"
      sudo "service nginx restart"
    end
  end

  task :restart_nginx do
    on roles(:all) do
      sudo "service nginx restart"
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'

  after 'deploy:publishing', 'deploy:restart'

  after :updating, 'deploy:symlink'

  before :setup, 'deploy:starting'
  before :setup, 'deploy:updating'
  before :setup, 'bundler:install'
end