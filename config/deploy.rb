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

set :test_deploy, true

set :master_data_file, 'NSPDC_AUG_2008_UK_100M.txt'

namespace :deploy do
  set :user, deployuser
  set :password, deploypassword

  desc "Set clear stored messages cron job"
  task :set_clear_messages_cron_job, :roles => :app do
    weeks_to_keep = ENV['weeks_to_keep']
    unless weeks_to_keep
      puts
      puts 'must supply weeks_to_keep when setting cron job'
      puts 'USAGE: cap deploy:set_clear_stored_messages_cron_job weeks_to_keep=6'
      puts
    else
      cmd = "05 4 * * * cd #{release_path}; rake fymp:clear_stored_messages weeks_to_keep=#{weeks_to_keep} RAILS_ENV=production"
      set_cron_job cmd, 'clear_stored_messages'
    end
  end

  desc "Set ar_sendmail cron job"
  task :set_ar_sendmail_cron_job, :roles => :app do
    batch_size = ENV['batch_size']
    freq_in_minutes = ENV['freq_in_mins']
    unless batch_size && freq_in_minutes
      puts
      puts 'must supply batch_size and freq_in_minutes when setting cron job'
      puts 'USAGE: cap deploy:set_ar_sendmail_cron_job batch_size=100 freq_in_mins=5'
      puts
    else
      cmd = "*/#{freq_in_minutes} * * * * /usr/local/bin/ar_sendmail -o --batch-size #{batch_size} --chdir #{deploy_to}/current --environment production"
      set_cron_job cmd, 'ar_sendmail'
    end
  end

  desc "Set db backup cron job"
  task :set_db_backup_cron_job, :roles => :app do
    cmd = "02 3 * * * cd #{release_path}; rake fymp:backup_db_s3 path=db/backup RAILS_ENV='production'"
    set_cron_job cmd, 'backup_database_to_S3'
  end
  
  desc "Set db backup cleanup cron job"
  task :set_db_backup_cleanup_cron_job, :roles => :app do
    cmd = "42 3 * * * cd #{release_path}; rake fymp:cleanup_db_backup files=42 RAILS_ENV='production'"
    set_cron_job cmd, 'S3_backup_cleanup'
  end

  def set_cron_job cmd, identifier
    tmpname = "/tmp/appname-crontab.#{Time.now.strftime('%s')}"
    run "(crontab -l || echo '') | grep -v '#{identifier}' > #{tmpname}"
    run %Q|echo "#{cmd}" >> #{tmpname}|
    run "crontab #{tmpname}"
    run "rm #{tmpname}"
  end

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

  desc "Upload S3 data files"
  task :put_s3_data, :roles => :app do
    data = File.read("config/virtualserver/deployed_s3.yml")
    put data, "#{release_path}/config/s3.yml", :mode => 0664

    data = File.read("config/virtualserver/fymp-public.pem")
    put data, "#{release_path}/config/fymp-public.pem", :mode => 0664
  end

  task :link_to_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"
    run "if [ -d #{data_dir} ]; then ln -s #{data_dir} #{release_path}/data ; else echo cap deploy put_data first ; fi"
  end

  desc 'put data to server'
  task :put_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"

    if overwrite
      run "if [ -d #{data_dir} ]; then echo #{data_dir} exists ; else mkdir #{data_dir} ; fi"

      run "rm #{data_dir}/FYMP_all.txt"
      put_data data_dir, 'FYMP_all.txt'

      run "rm #{data_dir}/constituencies.txt"
      put_data data_dir, 'constituencies.txt'

      if test_deploy
        run "rm #{data_dir}/postcodes.txt"
        put_data data_dir, 'postcodes.txt'
      else
        run "rm #{data_dir}/#{master_data_file}"
        put_data data_dir, "#{master_data_file}"
      end
    end

    log_dir = "#{deploy_to}/shared/log"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; fi"

    run "if [ -d #{deploy_to}/shared/system ]; then echo exists ; else mkdir #{deploy_to}/shared/system ; fi"

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

  def prompt_for_value(var)
    puts ""
    puts "*************************************"
    answer = ""
    message = "Do you want to overwrite the data?\n\nIf yes, type: YES, OVERWRITE!!\n(To continue without overwriting, just hit return)\n"
    answer = Capistrano::CLI.ui.ask(message)
    if answer == "YES, OVERWRITE!!"
      set var, true
    else
      set var, false
    end
  end
  
  def check_correct_ip
    puts ""
    puts "*************************************"
    answer = "n"
    
    servers = roles[:app].servers.uniq!.join(", ")
    
    message = "You are about to deploy to: #{servers} do you want to continue? (y/N)\n"
    answer = Capistrano::CLI.ui.ask(message)
    answer = "n" if answer == ""
    unless answer.first.downcase == "y"
      raise "Deploy aborted by user"
    end
  end

  desc "Restarting apache and clearing the cache"
  task :restart, :roles => :app do
    sudo "/usr/sbin/apache2ctl restart"
    run "cd #{current_path}; rake fymp:cache:expire_pages RAILS_ENV='production'"
  end

  desc "Perform rake tasks"
  task :rake_tasks, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; rake db:migrate RAILS_ENV='production'"

    if overwrite
      run "cd #{current_path}; rake fymp:constituencies RAILS_ENV='production'"
      run "cd #{current_path}; rake fymp:members RAILS_ENV='production'"

      run "cd #{current_path}; rake fymp:parse RAILS_ENV='production'" unless test_deploy
      run "cd #{current_path}; rake fymp:populate RAILS_ENV='production'"
    end

    run "cd #{current_path}; rake fymp:load_postcode_districts RAILS_ENV='production'"
  end

  task :check_folder_setup, :roles => :app do
    if is_first_run?
      set :overwrite, true
    else
      prompt_for_value(:overwrite)
    end

    puts 'checking folders...'
    run "if [ -d #{deploy_to} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'not there'
        folders = deploy_to.split("/")
        folderpath = ""
        folders.each do |folder|
          if folder != ""
            folderpath << "/" << folder
            run "if [ -d #{folderpath} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
              if message.strip == 'not there'
                sudo "mkdir #{folderpath}"
              end
            end
          end
        end
        sudo "chown #{user} #{folderpath}"
        run "mkdir #{folderpath}/releases"
      end
    end
    puts 'checks complete!'
  end

  task :check_server, :roles => :app do
    check_correct_ip
    run "git --help" do |channel, stream, message|
      if message =~ /No such file or directory/
        raise "You need to install git before proceeding"
      end
    end
  end

  task :check_site_setup, :roles => :app do
    if is_first_run?
      site_setup
    else
      rake_tasks
    end
  end

  task :site_setup, :roles => :app do
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

    run "sudo mysql -uroot -p", :pty => true do |ch, stream, data|
      # puts data
      if data =~ /Enter password:/
        ch.send_data(sql_server_password + "\n")
      else
        ch.send_data("create database #{application}_production CHARACTER SET utf8 COLLATE utf8_unicode_ci; \n")
        ch.send_data("create database #{application}_development CHARACTER SET utf8 COLLATE utf8_unicode_ci; \n")
        ch.send_data("create user '#{sql_backup_user}'@'localhost' identified by '#{sql_backup_password}'; \n")
        ch.send_data("grant SELECT, LOCK TABLES on #{application}_production.* to '#{sql_backup_user}'@'localhost'; \n")
        ch.send_data("grant SHOW DATABASES, RELOAD on *.* to '#{sql_backup_user}'@'localhost'; \n")
        ch.send_data("FLUSH PRIVILEGES; \n")
        ch.send_data("exit \n")
      end
    end

    sudo "gem sources -a http://gems.github.com"
    sudo "gem install hpricot"
    sudo "gem install morph"
    sudo "gem install unicode"
    sudo "gem install treetop"
    sudo "gem install term-ansicolor"
    sudo "gem install aws-s3 --version '0.5.1'"
    sudo "gem install adzap-ar_mailer --version '2.0.0'"
    sudo "cp /var/lib/gems/1.8/bin/ar_sendmail /usr/local/bin/ar_sendmail"

    rake_tasks

    sudo "/usr/sbin/apache2ctl restart"
    puts 'first time only setup complete!'
  end

  [:start, :stop].each do |t|
    desc "#{t} task is not used with mod_rails"
    task t, :roles => :app do ; end
  end

  def is_first_run?
    run "if [ -f /etc/apache2/sites-available/#{application} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'not there'
        return true
      else
        return false
      end
    end
  end

end

before 'deploy:update_code', 'deploy:check_server', 'deploy:check_folder_setup'
after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:upload_deployed_mailer_yml', 'deploy:put_s3_data', 'deploy:put_data', 'deploy:link_to_data'
after 'deploy', 'deploy:check_site_setup'


namespace :fymp do
  namespace :cache do
    set :remote_rake_cmd, "/usr/local/bin/rake"

    desc "Expire page cache"
    task :expire_pages, :roles => :app do
      run("export RAILS_ENV=production; cd #{deploy_to}/current; #{remote_rake_cmd} fymp:cache:expire_pages")
    end
  end
end
