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

end
