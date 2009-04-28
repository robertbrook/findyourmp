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

  task :run_ar_sendmail do
    batch_size = ENV['batch_size']
    deploy_dir = ENV['deploy_dir']
    environment = ENV['environment']

    if batch_size && deploy_dir && environment
      cmd = "ps -A | grep ar_sendmail | grep -v 'grep' | grep -v 'run_ar_sendmail' | wc -l"
      process_count = `#{cmd}`.strip
      puts process_count.to_s
      running = process_count == '1'
      puts running.to_s

      unless running
        cmd = "/usr/local/bin/ar_sendmail -o --batch-size #{batch_size} --chdir #{deploy_dir} --environment #{environment}"
        `#{cmd}`
      end
    else
      puts 'USAGE: rake fymp:run_ar_sendmail batch_size=10 deploy_dir=/apps/current environment=production'
    end
  end
end
