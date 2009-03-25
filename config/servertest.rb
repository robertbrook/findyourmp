load File.expand_path(File.dirname(__FILE__) + '/virtualserver/test_secrets.rb')

namespace :servertest do
  desc "Set up the siege box"
  task :setup, :roles => :siege do
    set :user, siege_user
    set :password, siege_password
    
    set :use_sudo, false
    
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
    
    tempfile = File.new("data/emails.txt",  "w")
    
    counter = 1
    recipient_counter = 0
    emails_to_send.times do
      subject = "Subject: Test - Bulk Message #{counter} of #{emails_to_send}"
      message = "Bulk message #{counter}"
      counter+=1
      recipient = email_recipients[recipient_counter]
      recipient_counter += 1
      recipient_counter = 0 if recipient_counter >= email_recipients.length
      tempfile.puts "#{email_sender} \t #{recipient} \t #{subject} \t #{message}"
    end
    
    tempfile.close_write
    data = File.read("data/emails.txt")
    File.delete("data/emails.txt")
    
    put data, "#{current_path}/data/emails.txt", :mode => 0664
    
    run "cd #{current_path};rake fymp:bulk_email RAILS_ENV='development'"
    run "rm #{current_path}/data/emails.txt"
    
    run "cd #{current_path};ar_sendmail -e 'development' -o"
  end
end
