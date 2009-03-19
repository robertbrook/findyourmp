namespace :fymp do

  desc "Populate data for constituencies in DB"
  task :dummy_email => :environment do
    email = Email.create :from => 'rob@movingflow.co.uk', :to => 'rob@movingflow.co.uk',
    :mail=>"Subject: yo\n
hi!"
    puts email.inspect.to_s
  end

end
