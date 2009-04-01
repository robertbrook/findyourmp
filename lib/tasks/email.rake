namespace :fymp do

  desc "Populate data for Bulk Email test in DB"
  task :bulk_email => :environment do
    raise 'can only be run in the development environment' unless RAILS_ENV == "development"

    data_dir = File.expand_path(File.dirname(__FILE__) + '/../../data')
    email_file = "#{data_dir}/emails.txt"

    IO.foreach(email_file) do |line|
      parts = line.split("\t")
      sender = parts[0].strip
      recipient = parts[1].strip

      message = "From: " << sender << "\r\nTo:" << recipient << "\r\n" << parts [2].strip << "\r\nMime-Version: 1.0\r\nContent-Type: text/plain; charset=utf-8" << "\r\n\r\n\n" << parts[3].strip

      Email.create :from => sender, :to => recipient, :mail => message
    end
  end

end
