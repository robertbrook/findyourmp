load File.expand_path(File.dirname(__FILE__) + '/virtualserver/test_secrets.rb')

namespace :servertest do
  desc "Set up the siege box"
  task :setup, :roles => :siege do
    set :user, siege_user
    set :password, siege_password
    
    data = File.read("config/virtualserver/url-stress-test.txt")
    put data, "url-stress-test.txt", :mode => 0664
    
    data = File.read("config/virtualserver/url-speed-test.txt")
    put data, "url-speed-test.txt", :mode => 0664
  end

  desc "Run the concurrent users test"
  task :concurrent, :roles => :siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c285 -r40 -i -f url-speed-test.txt -b"
  end
  
  desc "Run the response time test"
  task :response_time, :roles => :siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c20 -r40 -i -f url-stress-test.txt"
  end
  
  desc "Run the response time (light) test"
  task :response_time_light, :roles => :siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c20 -r40 -i -f url-speed-test.txt"
  end
  
  desc "Stress test the email sending capability"
  task :email, :roles => :app do
    run "cd #{current_path}; rake db:migrate RAILS_ENV='development'"
    
    tempfile = File.new("#{current_path}/data/emails.txt",  "w+")
    
    counter = 1
    emails_to_send.times do
      message = "Subject: Test - Bulk Message #{counter} of #{emails_to_send}\r\nBulk message #{counter}"
      counter+=1
      tempfile.puts "#{email_sender}\t#{email_recipient}\t"
    end
    
    sudo "cd #{current_path}; rake fymp:bulk_email RAILS_ENV='development'"
    File.delete(tempfile)
    
    sudo "ar_sendmail -e 'development' -b #{emails_to_send}"
  end
end
