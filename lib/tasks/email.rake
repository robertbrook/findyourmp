namespace :fymp do

  desc "Populate data for constituencies in DB"
  task :dummy_email => :environment do
    email = Email.create :from => 'rob@movingflow.co.uk', :to => 'rob@movingflow.co.uk',
    :mail=>"Subject: yo\n
hi!"
    puts email.inspect.to_s
  end
  
  desc "Populate data for Bulk Email test in DB"
  task :bulk_email => :environment do
    raise 'can only be run in the development environment' unless RAILS_ENV == "development"
    
    data_dir = File.expand_path(File.dirname(__FILE__) + '/../data')
    email_file = "#{data_dir}/emails.txt"
    
    IO.foreach(email_file) do |line|
      parts = line.split("\t")
      sender = parts[0].strip
      recipient = parts[1].strip
      message = parts[2].strip
      
      Email.create :from => sender, :to => recipient, :mail => message
    end
    
  end
end
