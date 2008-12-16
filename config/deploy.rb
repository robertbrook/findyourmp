load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

default_run_options[:pty] = true
set :repository,  "git://github.com/robertbrook/findyourmp.git"
set :scm, :git

ssh_options[:forward_agent] = true

set :branch, "master"

set :deploy_via, :remote_cache

set :git_enable_submodules, 1

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do

  desc "Upload deployed database.yml"
  task :upload_deployed_database_yml, :roles => :app do
    data = File.read("config/virtualserver/deployed_database.yml")
    put data, "#{release_path}/config/database.yml", :mode => 0664
  end

  task :link_to_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"
    run "if [ -d #{data_dir} ]; then ln -s #{data_dir} #{release_path}/data ; else echo cap deploy put_data first ; fi"
  end

  desc 'put data to server'
  task :put_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"
    run "if [ -d #{data_dir} ]; then echo #{data_dir} exists ; else mkdir #{data_dir} ; fi"

    put_data data_dir, 'ConstituencyToMember.txt'
    put_data data_dir, 'constituencies.txt'
    put_data data_dir, 'postcodes.txt'
    
    log_dir = "#{deploy_to}/shared/log"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; fi"
  end

  def put_data data_dir, file
    data_file = "#{data_dir}/#{file}"

    run "if [ -f #{data_file} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'not there'
        puts "sending #{file}"
        data = File.read("data/#{file.gsub('\\','')}")
        put data, "#{data_file}", :mode => 0664
      else
        puts "#{file} #{message}"
      end
    end
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is not used with mod_rails"
    task t, :roles => :app do ; end
  end

end

after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:put_data', 'deploy:link_to_data'


