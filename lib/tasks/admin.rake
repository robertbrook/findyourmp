namespace :fymp do

  desc "Create initial admin user"
  task :create_admin_user => :environment do
    unless ENV['password'] && ENV['email']
      puts 'must supply password and email for the new admin user'
      puts 'USAGE: rake fymp:create_admin_user password=pass email=admin@host.com'
    else
      password = ENV['password']
      email    = ENV['email']
      User.create_admin_user(password, email)
    end
  end

end
