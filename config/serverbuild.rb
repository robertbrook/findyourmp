load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')
  
role :app, domain

set :user, builduser
set :password, buildpassword

namespace :serverbuild do

  desc "Install Passenger including all prerequisites and restart Apache"
  task :default do
    aptget_config
    install_prereqs
    install_passenger
    passenger_apache_conf
  end
  
  desc "Replace the apt-get source list file"
  task :aptget_config, :roles => :app do
    data = ""
    tempfile = "config/sourcelist.tmp"
    
    get "/etc/apt/sources.list", tempfile
    
    oldfile = File.read(tempfile)
    
    data << "deb ftp://ftp.us.debian.org/debian etch main\n"
    data << "deb ftp://mirror.ox.ac.uk/debian etch main\n"
    data << "deb ftp://ftp.uk.debian.org/debian etch main\n"
    
    #oldfile.each { |line|
    #  data << line
    #}
    
    File.delete(tempfile)
    
    data << "deb http://us.archive.ubuntu.com/ubuntu/ gutsy universe\n"
    data << "deb-src http://us.archive.ubuntu.com/ubuntu/ gutsy universe\n"
    
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

  desc "Install Passenger prerequisites"
  task :install_prereqs, :roles => :app do
    sudo "apt-get update -y"
    sudo "apt-get install build-essential -y --force-yes"
    sudo "apt-get install apache2-prefork-dev -y --force-yes"
  end

  desc "Install Passenger"
  task :install_passenger, :roles => :app  do
    #install the latest version of the gem
    sudo "gem install passenger"

    #go to the the gem directory and run the rake task to build and install passenger
    run <<-EOB
       cd /var/lib/gems/1.8/gems/passenger-#{get_passenger_version} &&
       sudo rake clean apache2
    EOB
  end
  
  desc "Add Passenger stuff to apache config and restart apache"
  task :passenger_apache_conf, :roles => :app  do
    data = ""
    gemversion = get_passenger_version
    
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
  
end
