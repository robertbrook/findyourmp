load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')
  
role :app, domain

namespace :serverbuild do
  set :user, deployuser
  set :password, deploypassword
  
  set :use_sudo, false

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

  desc "Install Passenger prerequisites"
  task :install_prereqs, :roles => :app do
    sudo "apt-get update -y"
    sudo "apt-get install build-essential -y --force-yes"   
    sudo "apt-get install libpq5=8.3.4-2.2 -y --force-yes"
    sudo "apt-get install libpq-dev -y --force-yes"
    sudo "apt-get install libaprutil1-dev -y --force-yes"
    sudo "apt-get install apache2-prefork-dev -y --force-yes"
  end

  desc "Install Passenger"
  task :install_passenger, :roles => :app  do
    sudo "gem install passenger"

    sudo "chown -R #{passengeruser} /var/lib/gems/1.8/gems/passenger-#{get_passenger_version}"
    
    run "cd /var/lib/gems/1.8/gems/passenger-#{get_passenger_version}; sudo rake clean apache2"
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
