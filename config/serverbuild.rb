load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

role :app, domain

set :user, builduser
set :password, buildpassword

set :passengeruser, appuser

namespace :serverbuild do

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
        sudo "rm /etc/apache2/apache2.conf"
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
  
end
