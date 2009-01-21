load File.expand_path(File.dirname(__FILE__) + '/virtualserver/conf_secrets.rb')

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :app, domain

namespace :serverconfig do

  desc "Setup users for new box - only run once!"
  task :default do
    set :user, firsttimeuser
    set :password, firsttimepassword
    
    create_deploy_user
    create_passenger_user
    change_cftuser_password
  end
  
  task :create_deploy_user do
    create_user deployuser, deploygroup, deploypassword
  end
  
  task :create_passenger_user do
    create_user passengeruser, passengergroup, passengerpassword
  end
  
  def change_cftuser_password
    change_password 'cftuser', randompassword
  end
  
  def create_user username, group, newpassword    
    run "if [ -d /home/#{username} ]; then echo exists ; else echo not found ; fi", :pty => true do |ch, stream, data|
      if data =~ /not found/
        sudo "mkdir /home/#{username}"
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