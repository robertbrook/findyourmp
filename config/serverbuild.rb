load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')
  
role :app, domain
set :passenger_version, '2.1.2'

namespace :serverbuild do
  set :user, deployuser
  set :password, deploypassword
  
  set :use_sudo, false

  desc "Install Passenger including all prerequisites and restart Apache"
  task :default do
    setup_users
    aptget_config
    install_prereqs
    install_passenger
    passenger_apache_conf
  end
  
  desc "Replace the apt-get source list file"
  task :aptget_config, :roles => :app do
    data = ""
    tempfile = "config/sourcelist.tmp"
    
    sudo "chown #{user} /etc/apt/sources.list"
    get "/etc/apt/sources.list", tempfile
    
    oldfile = File.read(tempfile)
    
    # this code has been removed so that the original sources.list
    # entries are no longer used as the ones found in 
    # elasticserver's original file tend to be problematic
    #oldfile.each { |line|
    #  data << line
    #}
    
    File.delete(tempfile)
        
    data << "deb http://us.archive.ubuntu.com/ubuntu intrepid universe\n"
    data << "deb-src http://us.archive.ubuntu.com/ubuntu intrepid universe\n"
    data << "deb-src http://us.archive.ubuntu.com/ubuntu intrepid main\n"

    data << "deb http://fr.archive.ubuntu.com/ubuntu intrepid main\n"
    data << "deb http://nl.archive.ubuntu.com/ubuntu intrepid main\n"
    
    
    run "if [ -f /etc/apt/sources.list.bak ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'exists'
        sudo "rm /etc/apt/sources.list.bak"
      end
    end
  
    run "if [ -f /etc/apt/sources.list ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'exists'
        sudo "cp /etc/apt/sources.list /etc/apt/sources.list.bak"
        sudo "chown #{user} /etc/apt/sources.list"
      end
    end
    
    put data, "/etc/apt/sources.list", :mode => 0664
  end
  
  desc "Sort out the user credentials"
  task :setup_users, :roles => :app do
    set :user, firsttimeuser
    set :password, firsttimepassword
    
    create_deploy_user
    create_passenger_user
    change_cftuser_password
    
    sudo "mysqladmin -u root password \"#{sql_server_password}\""
  end

  desc "Install Passenger prerequisites"
  task :install_prereqs, :roles => :app do
    sudo "apt-get update -y"
    sudo "apt-get install build-essential -y --force-yes"   
    sudo "apt-get install libpq5=8.3.4-2.2 -y --force-yes"
    sudo "apt-get install libpq-dev -y --force-yes"
    sudo "apt-get install libaprutil1-dev -y --force-yes"
    sudo "apt-get install apache2-prefork-dev -y --force-yes"
    # sudo "apt-get install libruby1.8=1.8.7.72-1 -y --force-yes"
    #     sudo "apt-get install ruby1.8-dev -y --force-yes"
    #     sudo "apt-get install rdoc -y --force-yes"
    sudo "gem sources -a http://gems.github.com"
  end

  desc "Install Passenger"
  task :install_passenger, :roles => :app  do
    sudo "gem install passenger #{passenger_version}"

    sudo "chown -R #{passengeruser} /var/lib/gems/1.8/gems/passenger-#{passenger_version}"
    
    #run "cd /var/lib/gems/1.8/gems/passenger-#{passenger_version}; sudo rake clean apache2"
    sudo "/var/lib/gems/1.8/gems/passenger-#{passenger_version}/bin/passenger-install-apache2-module --auto"
  end
  
  desc "Add Passenger stuff to apache config and restart apache"
  task :passenger_apache_conf, :roles => :app  do
    data = ""
    gemversion = passenger_version
    
    source = File.read("config/apache2.conf.example")
    
    source.each { |line|
      line.gsub!("[PASSENGER-VERSION]", gemversion)
      line.gsub!("[PASSENGER-USER]", passengeruser)
      data << line
    }
    
    run "if [ -f /etc/apache2/apache2.conf ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
      if message.strip == 'exists'
        sudo "chown #{user} /etc/apache2/apache2.conf"
      end
    end
          
    put data, "/etc/apache2/apache2.conf", :mode => 0664
    
    sudo "/usr/sbin/apache2ctl restart"
  end
  
  def get_passenger_version
    gemversion = ""
    
    #find out what version of Passenger is installed
    run "gem list passenger" do |ch, stream, response|
      gemversion = response.strip.match('[0-9]*\.[0-9]*\.[0-9]*').to_s
    end
    
    gemversion
  end
  
  def create_deploy_user
    create_user deployuser, deploygroup, deploypassword
  end
  
  def create_passenger_user
    create_user passengeruser, passengergroup, passengerpassword
  end
  
  def change_cftuser_password
    change_password 'cftuser', randompassword
  end
  
  def create_user username, group, newpassword    
    run "if [ -d /home/#{username} ]; then echo exists ; else echo not found ; fi", :pty => true do |ch, stream, data|
      if data =~ /not found/
        sudo "mkdir /home/#{username}"
        sudo "chown #{username} /home/#{username}"
      end
    end
    
    begin
      sudo "grep '^#{group}:' /etc/group"
    rescue 
      sudo "groupadd #{group}"
    end
    
    begin
      sudo "grep '^#{username}:' /etc/passwd"
    rescue 
      sudo "useradd -g #{group} -s /bin/bash #{username}"
    end
    
    change_password username, newpassword
  end
    
  def change_password username, newpassword    
    run "sudo passwd #{username}", :pty => true do |ch, stream, data|
      puts data
      if data =~ /Enter new UNIX password:/ or data =~ /Retype new UNIX password:/
        ch.send_data(newpassword + "\n")
      else
        Capistrano::Configuration.default_io_proc.call(ch, stream, data)
      end
    end
  end

end
