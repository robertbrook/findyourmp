load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

role :app, domain
set :passenger_path, '/var/lib/gems/1.8/gems/passenger-2.1.2/bin'

namespace :passenger do
  desc "Display the memory stats info"
  task :memory_stats do
    sudo "#{passenger_path}/passenger-memory-stats"
  end
  
  desc "Display detailed status info"
  task :status do
    sudo "#{passenger_path}/passenger-status"
  end
end