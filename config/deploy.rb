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

  desc "Upload deployed mailer.yml"
  task :upload_deployed_mailer_yml, :roles => :app do
    data = File.read("config/virtualserver/deployed_mailer.yml")
    put data, "#{release_path}/config/mailer.yml", :mode => 0664
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

    run "if [-d #{deploy_to}/shared/system ]; then echo exists ; else mkdir #{deploy_to}/shared/system ; fi"

    rc_rake_file = "#{release_path}/vendor/plugins/resource_controller/tasks/gem.rake"
    run "if [ -f #{rc_rake_file} ]; then mv #{rc_rake_file} #{rc_rake_file}.bak ; else echo not found ; fi"
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
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Perform non-destructive rake tasks"
  task :rake_tasks, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; rake db:migrate RAILS_ENV='production'"
    run "cd #{current_path}; rake fymp:constituencies RAILS_ENV='production'"
    run "cd #{current_path}; rake fymp:members RAILS_ENV='production'"
  end

  task:check_folder_setup do
    puts 'checking folders...'
    run "if [ -d #{deploy_to} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'not there'
        folders = deploy_to.split("/")
        folderpath = ""
        folders.each do |folder|
          if folder != ""
            folderpath << "/" << folder
            run "if [ -d #{folderpath} ]; then echo exists ; else sudo mkdir #{folderpath} ; fi"
          end
        end
        sudo "chown #{user} #{folderpath}"
        run "mkdir #{folderpath}/releases"
      end
    end
    puts 'checks complete!'
  end

  task :check_server do
    run "sudo which git" do |channel, stream, message|
      if message == ''
        raise "You need to install git before proceeding"
      end
    end
  end

  task :check_site_setup do
    run "if [ -f /etc/apache2/sites-available/#{application} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'not there'
        site_setup
      else
        rake_tasks
      end
    end
  end

  task :site_setup do
    puts 'entering first time only setup...'

    sudo "touch /etc/apache2/sites-available/#{application}"
    sudo "chown #{user} /etc/apache2/sites-available/#{application}"

    source = File.read("config/findyourmp.apache.example")
    data = ""
    source.each { |line|
      line.gsub!("[RELEASE-PATH]", deploy_to)
      data << line
    }
    put data, "/etc/apache2/sites-available/#{application}", :mode => 0664

    sudo "sudo ln -s -f /etc/apache2/sites-available/#{application} /etc/apache2/sites-enabled/000-default"

    sudo "mysqladmin create #{application}_production"

    sudo "gem install hpricot"
    sudo "gem install morph"
    sudo "gem install unicode"

    rake_tasks
    # uncomment the line below to run a full parse - removed for testing (takes too long)
    #run "cd #{current_path}; rake fymp:parse RAILS_ENV='production'"
    run "cd #{current_path}; rake fymp:populate RAILS_ENV='production'"

    sudo "/usr/sbin/apache2ctl restart"
    puts 'first time only setup complete!'
  end

  [:start, :stop].each do |t|
    desc "#{t} task is not used with mod_rails"
    task t, :roles => :app do ; end
  end

end

before 'deploy:update_code', 'deploy:check_server', 'deploy:check_folder_setup'
after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:upload_deployed_mailer_yml', 'deploy:put_data', 'deploy:link_to_data'
after 'deploy', 'deploy:check_site_setup'


