load File.expand_path(File.dirname(__FILE__) + '/virtualserver/test_secrets.rb')

namespace :servertest do
  desc "Set up the siege box"
  task :setup, :hosts => siege do
    set :user, siege_user
    set :password, siege_password

    set :use_sudo, false

    data = File.read("config/virtualserver/url-stress-test.txt")
    put data, "url-stress-test.txt", :mode => 0664

    data = File.read("config/virtualserver/url-speed-test.txt")
    put data, "url-speed-test.txt", :mode => 0664
  end

  desc "Run the concurrent users test"
  task :concurrent, :hosts => siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c275 -r42 -i -f url-speed-test.txt -b"
  end

  desc "Run the response time test"
  task :response_time, :hosts => siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c20 -r40 -i -f url-stress-test.txt"
  end

  desc "Run the response time (light) test"
  task :response_time_light, :hosts => siege do
    set :user, siege_user
    set :password, siege_password
    sudo "siege -c20 -r40 -i -f url-speed-test.txt"
  end

  desc "Set up a dummy mail queue for testing the email sending capability"
  task :setup_email, :roles => :app do
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
  end
end
