namespace :fymp do

  desc "Create initial admin user"
  task :create_admin_user => :environment do
    password = ENV['password']
    email    = ENV['email']
    unless password && email
      puts 'must supply password and email for the new admin user'
      puts 'USAGE: rake fymp:create_admin_user password=pass email=admin@host.com'
    else
      User.create_admin_user(password, email)
    end
  end

  task :clear_stored_messages => :environment do
    weeks_to_keep = ENV['weeks_to_keep']
    if weeks_to_keep
      Message.clear_stored_messages weeks_to_keep.to_i
    else
      puts 'USAGE: rake fymp:clear_stored_messages weeks_to_keep=6 RAILS_ENV=production'
    end
  end
end
