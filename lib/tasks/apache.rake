namespace :apache do
  
  desc "Shut down the Apache server"
  task :shutdown do
    system "sudo /etc/init.d/apache2 stop"
  end
  
  desc "Start the Apache server"
  task :start do
    system "sudo /etc/init.d/apache2 start"
  end
end